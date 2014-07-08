/*
Copyright (c) 2011, Adobe Systems Incorporated
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

* Neither the name of Adobe Systems Incorporated nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package com.adobe.utils;

import flash.display3D.Context3DProgramType;
import flash.utils.ByteArray;
import flash.utils.Endian;
import haxe.ds.StringMap;

using StringTools;

class AGALMiniAssembler
{

	private static inline var USE_NEW_SYNTAX:Bool = false;

	// ======================================================================
	//  Properties
	// ----------------------------------------------------------------------
	// AGAL bytes and error buffer
	public var error(default, null):String = "";
	public var agalcode(default, null):ByteArray;

	private var debugEnabled:Bool = false;

	private static var initialized:Bool = false;
	private var verbose:Bool = false;

	// ======================================================================
	//  Constructor
	// ----------------------------------------------------------------------
	public function new(debugging:Bool = false):Void
	{
		debugEnabled = debugging;
		if (!initialized) init();
	}

	private function match(str:String, reg:EReg, extract:Int=0):Array<String>
	{
		var matches = new Array<String>();
		while (reg.match(str))
		{
			matches.push(reg.matched(extract));
			str = reg.matchedRight();
		}
		return matches;
	}

	// ======================================================================
	//  Methods
	// ----------------------------------------------------------------------
	public function assemble(mode:Context3DProgramType, source:String):ByteArray
	{
		var start:UInt = flash.Lib.getTimer();

		agalcode = new ByteArray();
		error = "";

		var isFrag:Bool = false;

		if (mode == Context3DProgramType.FRAGMENT)
			isFrag = true;
		else if (mode != Context3DProgramType.VERTEX)
			error = 'ERROR: mode needs to be "' + Context3DProgramType.FRAGMENT + '" or "' + Context3DProgramType.VERTEX + '" but is "' + mode + '".';

		agalcode.endian = Endian.LITTLE_ENDIAN;
		agalcode.writeByte(0xa0);            // tag version
		agalcode.writeUnsignedInt(0x1);      // AGAL version, big endian, bit pattern will be 0x01000000
		agalcode.writeByte(0xa1);            // tag program id
		agalcode.writeByte(isFrag ? 1 : 0);  // vertex or fragment

		var reg:EReg = ~/[\n\r]+/g;
		var lines:Array<String> = reg.replace(source, "\n").split("\n");
		var nest:Int = 0;
		var nops:Int = 0;
		var i:Int = 0;
		var lng:Int = lines.length;

		while (i < lng && error == "")
		{
			var line:String = lines[i].trim();

			// remove comments
			var startcomment:Int = line.indexOf("//");
			if (startcomment != -1) line = line.substr(0, startcomment);

			// grab options
			reg = ~/<.*>/g;
			var opts:Array<String> = [];
			if (reg.match(line))
			{
				var optsi = reg.matchedPos().pos;

				opts = match(line.substr(optsi), ~/([\w\.\-\+]+)/gi, 1);
				line = line.substr(0, optsi);
			}

			// find opcode
			reg = ~/^\w{3}/ig;
			if (!reg.match(line))
			{
				if (line.length >= 3)
					trace("warning: bad line " + i + ": " + lines[i]);
				i += 1;
				continue;
			}
			var opFound:OpCode = OPMAP.get(reg.matched(0));

			// if debug is enabled, output the opcodes
			if (debugEnabled) trace(opFound);

			if (opFound == null)
			{
				if (line.length >= 3)
					trace("warning: bad line " + i + ": " + lines[i]);
				i += 1;
				continue;
			}

			line = line.substr(line.indexOf(opFound.name) + opFound.name.length);

			// nesting check
			if ((opFound.flags & OP_DEC_NEST) != 0)
			{
				nest--;
				if (nest < 0)
				{
					error = "error: conditional closes without open.";
					break;
				}
			}
			if ((opFound.flags & OP_INC_NEST) != 0)
			{
				nest++;
				if (nest > MAX_NESTING)
				{
					error = "error: nesting to deep, maximum allowed is " + MAX_NESTING + ".";
					break;
				}
			}
			if (((opFound.flags & OP_FRAG_ONLY) != 0) && !isFrag)
			{
				error = "error: opcode is only allowed in fragment programs.";
				break;
			}
			if (verbose) trace("emit opcode=" + opFound);

			agalcode.writeUnsignedInt( opFound.emitCode );
			nops++;

			if (nops > MAX_OPCODES)
			{
				error = "error: too many opcodes. maximum is " + MAX_OPCODES + ".";
				break;
			}

			// get operands, use regexp
			var regs = match(line, USE_NEW_SYNTAX ?
				~/vc\[([vif][acost]?)(\d*)?(\.[xyzw](\+\d{1,3})?)?\](\.[xyzw]{1,4})?|([vif][acost]?)(\d*)?(\.[xyzw]{1,4})?/gi :
				~/vc\[([vof][actps]?)(\d*)?(\.[xyzw](\+\d{1,3})?)?\](\.[xyzw]{1,4})?|([vof][actps]?)(\d*)?(\.[xyzw]{1,4})?/gi);

			if (regs.length != Std.int(opFound.numRegister))
			{
				error = "error: wrong number of operands. found " + regs.length + " but expected " + opFound.numRegister + ".";
				break;
			}

			var badreg:Bool    = false;
			var pad:UInt       = 64 + 64 + 32;
			var regLength:UInt = regs.length;

			for (j in 0...Std.int(regLength))
			{
				var isRelative:Bool = false;
				reg = ~/\[.*\]/ig;
				var relreg = reg.replace(regs[j], "0");
				if (relreg != regs[j])
				{
					regs[j] = relreg;
					if (verbose) trace("IS REL");
					isRelative = true;
				}

				reg = ~/^\b[A-Za-z]{1,2}/ig;
				reg.match(regs[j]);
				var regFound:Register = REGMAP.get(reg.matched(0));

				// if debug is enabled, output the registers
				if (debugEnabled) trace(regFound);

				if (regFound == null)
				{
					error = "error: could not parse operand " + j + " (" + regs[j] + ").";
					badreg = true;
					break;
				}

				if (isFrag)
				{
					if ((regFound.flags & REG_FRAG) == 0)
					{
						error = "error: register operand " + j + " (" + regs[j] + ") only allowed in vertex programs.";
						badreg = true;
						break;
					}
					if (isRelative)
					{
						error = "error: register operand " + j + " (" + regs[j] + ") relative adressing not allowed in fragment programs.";
						badreg = true;
						break;
					}
				}
				else
				{
					if ((regFound.flags & REG_VERT) == 0)
					{
						error = "error: register operand " + j + " (" + regs[j] + ") only allowed in fragment programs.";
						badreg = true;
						break;
					}
				}

				regs[j] = regs[j].substr(regs[j].indexOf( regFound.name ) + regFound.name.length);
				//trace( "REGNUM: " +regs[j] );
				reg = ~/\d+/;
				var idxmatched:Bool = isRelative ? reg.match(relreg) : reg.match(regs[j]);
				var regidx:UInt = 0;

				if (idxmatched) regidx = Std.parseInt(reg.matched(0));

				if (regFound.range < regidx)
				{
					error = "error: register operand " + j + " (" + regs[j] + ") index exceeds limit of " + (regFound.range + 1) + ".";
					badreg = true;
					break;
				}

				var regmask:UInt   = 0;
				var isDest:Bool    = (j == 0 && (opFound.flags & OP_NO_DEST) == 0);
				var isSampler:Bool = (j == 2 && (opFound.flags & OP_SPECIAL_TEX) != 0);
				var reltype:UInt   = 0;
				var relsel:UInt    = 0;
				var reloffset:Int  = 0;

				if (isDest && isRelative)
				{
					error = "error: relative can not be destination";
					badreg = true;
					break;
				}

				reg = ~/(\.[xyzw]{1,4})/;
				if (reg.match(regs[j]))
				{
					var maskmatch:String = reg.matched(0);
					regmask = 0;
					var cv:UInt = 0;
					for (k in 1...maskmatch.length)
					{
						cv = maskmatch.charCodeAt(k) - "x".charCodeAt(0);
						if (cv > 2) cv = 3;

						if (isDest)
							regmask |= 1 << cv;
						else
							regmask |= cv << ( ( k - 1 ) << 1 );
					}
					if (!isDest)
					{
						var k = maskmatch.length;
						while (k <= 4)
						{
							regmask |= cv << ( ( k - 1 ) << 1 ); // repeat last
							++k;
						}
					}
				}
				else
				{
					regmask = isDest ? 0xf : 0xe4; // id swizzle or mask
				}

				if (isRelative)
				{
					reg = ~/[A-Za-z]{1,2}/ig;
					reg.match(relreg);
					var relname = reg.matched(0);

					if (REGMAP.exists(relname))
					{
						error = "error: bad index register";
						badreg = true;
						break;
					}
					else
					{
						reltype = REGMAP.get(relname).emitCode;
					}

					reg = ~/(\.[xyzw]{1,1})/;
					if (!reg.match(relreg))
					{
						error = "error: bad index register select";
						badreg = true;
						break;
					}
					var selmatch:String = reg.matched(0);
					relsel = selmatch.charCodeAt(1) - "x".charCodeAt(0);
					if (relsel > 2) relsel = 3;
					reg = ~/\+\d{1,3}/ig;
					if (reg.match(relreg))
					{
						reloffset = Std.parseInt(reg.matched(0));
					}
					if (reloffset < 0 || reloffset > 255)
					{
						error = "error: index offset " + reloffset + " out of bounds. [0..255]";
						badreg = true;
						break;
					}
					if (verbose) trace( "RELATIVE: type=" + reltype + "==" + relname + " sel=" + relsel + "==" + selmatch + " idx=" + regidx + " offset=" + reloffset);
				}

				if (verbose) trace("  emit argcode=" + regFound + "[" + regidx + "][" + regmask + "]");
				if (isDest)
				{
					agalcode.writeShort(regidx);
					agalcode.writeByte(regmask);
					agalcode.writeByte(regFound.emitCode);
					pad -= 32;
				}
				else
				{
					if (isSampler)
					{
						if (verbose) trace("  emit sampler");
						var samplerbits:UInt = 5; // type 5
						var bias:Float = 0;
						for (opt in opts)
						{
							if (verbose)
							{
								trace("    opt: " + opt);
							}

							if (SAMPLEMAP.exists(opt))
							{
								var optfound:Sampler = SAMPLEMAP.get(opt);

								if (optfound.flag != SAMPLER_SPECIAL_SHIFT)
								{
									samplerbits &= ~(0xf << optfound.flag);
								}

								samplerbits |= optfound.mask << optfound.flag;
							}
							else
							{
								// todo check that it's a number...
								//trace( "Warning, unknown sampler option: " + opt );
								bias = Std.parseFloat(opt);
								if (verbose)
								{
									trace("    bias: " + bias);
								}
							}
						}
						agalcode.writeShort(regidx);
						agalcode.writeByte(Std.int(bias * 8.0));
						agalcode.writeByte(0);
						agalcode.writeUnsignedInt(samplerbits);

						if (verbose) trace("    bits: " + ( samplerbits - 5 ));
						pad -= 64;
					}
					else
					{
						if (j == 0)
						{
							agalcode.writeUnsignedInt(0);
							pad -= 32;
						}
						agalcode.writeShort(regidx);
						agalcode.writeByte(reloffset);
						agalcode.writeByte(regmask);
						agalcode.writeByte(regFound.emitCode);
						agalcode.writeByte(reltype);
						agalcode.writeShort(isRelative ? ( relsel | ( 1 << 15 ) ):0);

						pad -= 64;
					}
				}
			}

			// pad unused regs
			for (j in 0...Std.int(pad / 8))
			{
				agalcode.writeByte(0);
			}

			if (badreg) break;
			++i;
		}

		if (error != "")
		{
			error += "\n  at line " + i + " " + lines[i];
			agalcode.length = 0;
			trace(error);
		}

		// trace the bytecode bytes if debugging is enabled
		if (debugEnabled)
		{
			var dbgLine:String = "generated bytecode:";
			var agalLength:UInt = agalcode.length;
			var index:UInt = 0;
			while (index < agalLength)
			{
				if (( index % 16) == 0) dbgLine += "\n";
				if ((index % 4) == 0) dbgLine += " ";

				var byteStr:String = Std.string(agalcode[index]);// .toString( 16 );
				if (byteStr.length < 2) byteStr = "0" + byteStr;

				dbgLine += byteStr;
				++index;
			}
			trace( dbgLine );
		}

		if (verbose) trace( "AGALMiniAssembler.assemble time: " + ( ( flash.Lib.getTimer() - start ) / 1000 ) + "s" );

		return agalcode;
	}

	static private function init():Void {
		initialized = true;

		// Fill the dictionaries with opcodes and registers
		OPMAP.set(MOV, new OpCode( MOV, 2, 0x00, 0 ));
		OPMAP.set(ADD, new OpCode( ADD, 3, 0x01, 0 ));
		OPMAP.set(SUB, new OpCode( SUB, 3, 0x02, 0 ));
		OPMAP.set(MUL, new OpCode( MUL, 3, 0x03, 0 ));
		OPMAP.set(DIV, new OpCode( DIV, 3, 0x04, 0 ));
		OPMAP.set(RCP, new OpCode( RCP, 2, 0x05, 0 ));
		OPMAP.set(MIN, new OpCode( MIN, 3, 0x06, 0 ));
		OPMAP.set(MAX, new OpCode( MAX, 3, 0x07, 0 ));
		OPMAP.set(FRC, new OpCode( FRC, 2, 0x08, 0 ));
		OPMAP.set(SQT, new OpCode( SQT, 2, 0x09, 0 ));
		OPMAP.set(RSQ, new OpCode( RSQ, 2, 0x0a, 0 ));
		OPMAP.set(POW, new OpCode( POW, 3, 0x0b, 0 ));
		OPMAP.set(LOG, new OpCode( LOG, 2, 0x0c, 0 ));
		OPMAP.set(EXP, new OpCode( EXP, 2, 0x0d, 0 ));
		OPMAP.set(NRM, new OpCode( NRM, 2, 0x0e, 0 ));
		OPMAP.set(SIN, new OpCode( SIN, 2, 0x0f, 0 ));
		OPMAP.set(COS, new OpCode( COS, 2, 0x10, 0 ));
		OPMAP.set(CRS, new OpCode( CRS, 3, 0x11, 0 ));
		OPMAP.set(DP3, new OpCode( DP3, 3, 0x12, 0 ));
		OPMAP.set(DP4, new OpCode( DP4, 3, 0x13, 0 ));
		OPMAP.set(ABS, new OpCode( ABS, 2, 0x14, 0 ));
		OPMAP.set(NEG, new OpCode( NEG, 2, 0x15, 0 ));
		OPMAP.set(SAT, new OpCode( SAT, 2, 0x16, 0 ));
		OPMAP.set(M33, new OpCode( M33, 3, 0x17, OP_SPECIAL_MATRIX ));
		OPMAP.set(M44, new OpCode( M44, 3, 0x18, OP_SPECIAL_MATRIX ));
		OPMAP.set(M34, new OpCode( M34, 3, 0x19, OP_SPECIAL_MATRIX ));
		OPMAP.set(IFZ, new OpCode( IFZ, 1, 0x1a, OP_NO_DEST | OP_INC_NEST | OP_SCALAR ));
		OPMAP.set(INZ, new OpCode( INZ, 1, 0x1b, OP_NO_DEST | OP_INC_NEST | OP_SCALAR ));
		OPMAP.set(IFE, new OpCode( IFE, 2, 0x1c, OP_NO_DEST | OP_INC_NEST | OP_SCALAR ));
		OPMAP.set(INE, new OpCode( INE, 2, 0x1d, OP_NO_DEST | OP_INC_NEST | OP_SCALAR ));
		OPMAP.set(IFG, new OpCode( IFG, 2, 0x1e, OP_NO_DEST | OP_INC_NEST | OP_SCALAR ));
		OPMAP.set(IFL, new OpCode( IFL, 2, 0x1f, OP_NO_DEST | OP_INC_NEST | OP_SCALAR ));
		OPMAP.set(IEG, new OpCode( IEG, 2, 0x20, OP_NO_DEST | OP_INC_NEST | OP_SCALAR ));
		OPMAP.set(IEL, new OpCode( IEL, 2, 0x21, OP_NO_DEST | OP_INC_NEST | OP_SCALAR ));
		OPMAP.set(ELS, new OpCode( ELS, 0, 0x22, OP_NO_DEST | OP_INC_NEST | OP_DEC_NEST ));
		OPMAP.set(EIF, new OpCode( EIF, 0, 0x23, OP_NO_DEST | OP_DEC_NEST ));
		OPMAP.set(REP, new OpCode( REP, 1, 0x24, OP_NO_DEST | OP_INC_NEST | OP_SCALAR ));
		OPMAP.set(ERP, new OpCode( ERP, 0, 0x25, OP_NO_DEST | OP_DEC_NEST ));
		OPMAP.set(BRK, new OpCode( BRK, 0, 0x26, OP_NO_DEST ));
		OPMAP.set(KIL, new OpCode( KIL, 1, 0x27, OP_NO_DEST | OP_FRAG_ONLY ));
		OPMAP.set(TEX, new OpCode( TEX, 3, 0x28, OP_FRAG_ONLY | OP_SPECIAL_TEX ));
		OPMAP.set(SGE, new OpCode( SGE, 3, 0x29, 0 ));
		OPMAP.set(SLT, new OpCode( SLT, 3, 0x2a, 0 ));
		OPMAP.set(SGN, new OpCode( SGN, 2, 0x2b, 0 ));
		OPMAP.set(SEQ, new OpCode( SEQ, 3, 0x2c, 0 ));
		OPMAP.set(SNE, new OpCode( SNE, 3, 0x2d, 0 ));

		REGMAP.set(VA, new Register(VA,  "vertex attribute",   0x0,   7, REG_VERT | REG_READ));
		REGMAP.set(VC, new Register(VC,  "vertex constant",    0x1, 127, REG_VERT | REG_READ));
		REGMAP.set(VT, new Register(VT,  "vertex temporary",   0x2,   7, REG_VERT | REG_WRITE | REG_READ));
		REGMAP.set(VO, new Register(VO,  "vertex output",      0x3,   0, REG_VERT | REG_WRITE));
		REGMAP.set( I, new Register( I,  "varying",            0x4,   7, REG_VERT | REG_FRAG | REG_READ | REG_WRITE));
		REGMAP.set(FC, new Register(FC,  "fragment constant",  0x1,  27, REG_FRAG | REG_READ));
		REGMAP.set(FT, new Register(FT,  "fragment temporary", 0x2,   7, REG_FRAG | REG_WRITE | REG_READ));
		REGMAP.set(FS, new Register(FS,  "texture sampler",    0x5,   7, REG_FRAG | REG_READ));
		REGMAP.set(FO, new Register(FO,  "fragment output",    0x3,   0, REG_FRAG | REG_WRITE));

		SAMPLEMAP.set(RGBA,       new Sampler(RGBA,        SAMPLER_TYPE_SHIFT,    0));
		SAMPLEMAP.set(DXT1,       new Sampler(DXT1,        SAMPLER_TYPE_SHIFT,    1));
		SAMPLEMAP.set(DXT5,       new Sampler(DXT5,        SAMPLER_TYPE_SHIFT,    2));
		SAMPLEMAP.set(D2,         new Sampler(D2,          SAMPLER_DIM_SHIFT,     0));
		SAMPLEMAP.set(D3,         new Sampler(D3,          SAMPLER_DIM_SHIFT,     2));
		SAMPLEMAP.set(CUBE,       new Sampler(CUBE,        SAMPLER_DIM_SHIFT,     1));
		SAMPLEMAP.set(MIPNEAREST, new Sampler(MIPNEAREST,  SAMPLER_MIPMAP_SHIFT,  1));
		SAMPLEMAP.set(MIPLINEAR,  new Sampler(MIPLINEAR,   SAMPLER_MIPMAP_SHIFT,  2));
		SAMPLEMAP.set(MIPNONE,    new Sampler(MIPNONE,     SAMPLER_MIPMAP_SHIFT,  0));
		SAMPLEMAP.set(NOMIP,      new Sampler(NOMIP,       SAMPLER_MIPMAP_SHIFT,  0));
		SAMPLEMAP.set(NEAREST,    new Sampler(NEAREST,     SAMPLER_FILTER_SHIFT,  0));
		SAMPLEMAP.set(LINEAR,     new Sampler(LINEAR,      SAMPLER_FILTER_SHIFT,  1));
		SAMPLEMAP.set(CENTROID,   new Sampler(CENTROID,    SAMPLER_SPECIAL_SHIFT, 1 << 0));
		SAMPLEMAP.set(SINGLE,     new Sampler(SINGLE,      SAMPLER_SPECIAL_SHIFT, 1 << 1));
		SAMPLEMAP.set(DEPTH,      new Sampler(DEPTH,       SAMPLER_SPECIAL_SHIFT, 1 << 2));
		SAMPLEMAP.set(REPEAT,     new Sampler(REPEAT,      SAMPLER_REPEAT_SHIFT,  1));
		SAMPLEMAP.set(WRAP,       new Sampler(WRAP,        SAMPLER_REPEAT_SHIFT,  1));
		SAMPLEMAP.set(CLAMP,      new Sampler(CLAMP,       SAMPLER_REPEAT_SHIFT,  0));
	}

	// ======================================================================
	//  Constants
	// ----------------------------------------------------------------------
	private static var OPMAP:StringMap<OpCode>      = new StringMap<OpCode>();
	private static var REGMAP:StringMap<Register>   = new StringMap<Register>();
	private static var SAMPLEMAP:StringMap<Sampler> = new StringMap<Sampler>();

	private static inline var MAX_NESTING:Int         = 4;
	private static inline var MAX_OPCODES:Int         = 256;

	private static inline var FRAGMENT:String         = "fragment";
	private static inline var VERTEX:String           = "vertex";

	// masks and shifts
	private static inline var SAMPLER_TYPE_SHIFT:UInt    = 8;
	private static inline var SAMPLER_DIM_SHIFT:UInt     = 12;
	private static inline var SAMPLER_SPECIAL_SHIFT:UInt = 16;
	private static inline var SAMPLER_REPEAT_SHIFT:UInt  = 20;
	private static inline var SAMPLER_MIPMAP_SHIFT:UInt  = 24;
	private static inline var SAMPLER_FILTER_SHIFT:UInt  = 28;

	// regmap flags
	private static inline var REG_WRITE:UInt           = 0x1;
	private static inline var REG_READ:UInt            = 0x2;
	private static inline var REG_FRAG:UInt            = 0x20;
	private static inline var REG_VERT:UInt            = 0x40;

	// opmap flags
	private static inline var OP_SCALAR:UInt            = 0x1;
	private static inline var OP_INC_NEST:UInt          = 0x2;
	private static inline var OP_DEC_NEST:UInt          = 0x4;
	private static inline var OP_SPECIAL_TEX:UInt       = 0x8;
	private static inline var OP_SPECIAL_MATRIX:UInt    = 0x10;
	private static inline var OP_FRAG_ONLY:UInt         = 0x20;
	// private static inline var OP_VERT_ONLY:UInt         = 0x40;
	private static inline var OP_NO_DEST:UInt           = 0x80;

	// opcodes
	private static inline var MOV:String  = "mov";
	private static inline var ADD:String  = "add";
	private static inline var SUB:String  = "sub";
	private static inline var MUL:String  = "mul";
	private static inline var DIV:String  = "div";
	private static inline var RCP:String  = "rcp";
	private static inline var MIN:String  = "min";
	private static inline var MAX:String  = "max";
	private static inline var FRC:String  = "frc";
	private static inline var SQT:String  = "sqt";
	private static inline var RSQ:String  = "rsq";
	private static inline var POW:String  = "pow";
	private static inline var LOG:String  = "log";
	private static inline var EXP:String  = "exp";
	private static inline var NRM:String  = "nrm";
	private static inline var SIN:String  = "sin";
	private static inline var COS:String  = "cos";
	private static inline var CRS:String  = "crs";
	private static inline var DP3:String  = "dp3";
	private static inline var DP4:String  = "dp4";
	private static inline var ABS:String  = "abs";
	private static inline var NEG:String  = "neg";
	private static inline var SAT:String  = "sat";
	private static inline var M33:String  = "m33";
	private static inline var M44:String  = "m44";
	private static inline var M34:String  = "m34";
	private static inline var IFZ:String  = "ifz";
	private static inline var INZ:String  = "inz";
	private static inline var IFE:String  = "ife";
	private static inline var INE:String  = "ine";
	private static inline var IFG:String  = "ifg";
	private static inline var IFL:String  = "ifl";
	private static inline var IEG:String  = "ieg";
	private static inline var IEL:String  = "iel";
	private static inline var ELS:String  = "els";
	private static inline var EIF:String  = "eif";
	private static inline var REP:String  = "rep";
	private static inline var ERP:String  = "erp";
	private static inline var BRK:String  = "brk";
	private static inline var KIL:String  = "kil";
	private static inline var TEX:String  = "tex";
	private static inline var SGE:String  = "sge";
	private static inline var SLT:String  = "slt";
	private static inline var SGN:String  = "sgn";
	private static inline var SEQ:String  = "seq";
	private static inline var SNE:String  = "sne";

	// registers
	private static inline var VA:String  = "va";
	private static inline var VC:String  = "vc";
	private static inline var VT:String  = "vt";
	private static inline var VO:String  = USE_NEW_SYNTAX ? "vo" : "op";
	private static inline var I:String   = USE_NEW_SYNTAX ? "i" : "v";
	private static inline var FC:String  = "fc";
	private static inline var FT:String  = "ft";
	private static inline var FS:String  = "fs";
	private static inline var FO:String  = USE_NEW_SYNTAX ? "fo" : "oc";

	// samplers
	private static inline var D2:String          = "2d";
	private static inline var D3:String          = "3d";
	private static inline var CUBE:String        = "cube";
	private static inline var MIPNEAREST:String  = "mipnearest";
	private static inline var MIPLINEAR:String   = "miplinear";
	private static inline var MIPNONE:String     = "mipnone";
	private static inline var NOMIP:String       = "nomip";
	private static inline var NEAREST:String     = "nearest";
	private static inline var LINEAR:String      = "linear";
	private static inline var CENTROID:String    = "centroid";
	private static inline var SINGLE:String      = "single";
	private static inline var DEPTH:String       = "depth";
	private static inline var REPEAT:String      = "repeat";
	private static inline var WRAP:String        = "wrap";
	private static inline var CLAMP:String       = "clamp";
	private static inline var RGBA:String        = "rgba";
	private static inline var DXT1:String        = "dxt1";
	private static inline var DXT5:String        = "dxt5";
}

// ================================================================================
//  Helper Classes
// --------------------------------------------------------------------------------

// ===========================================================================
//  Class
// ---------------------------------------------------------------------------
class OpCode
{
	// ======================================================================
	//  Properties
	// ----------------------------------------------------------------------
	public var emitCode(default, null):UInt;
	public var flags(default, null):UInt;
	public var name(default, null):String;
	public var numRegister(default, null):UInt;

	// ======================================================================
	//  Constructor
	// ----------------------------------------------------------------------
	public function new(name:String, numRegister:UInt, emitCode:UInt, flags:UInt)
	{
		this.name = name;
		this.numRegister = numRegister;
		this.emitCode = emitCode;
		this.flags = flags;
	}

	// ======================================================================
	//  Methods
	// ----------------------------------------------------------------------
	public function toString():String
	{
		return "[OpCode name=\"" + name + "\", numRegister=" + numRegister + ", emitCode=" + emitCode + ", flags=" + flags + "]";
	}
}

// ===========================================================================
//  Class
// ---------------------------------------------------------------------------
class Register
{
	// ======================================================================
	//  Properties
	// ----------------------------------------------------------------------
	public var emitCode(default, null):UInt;
	public var name(default, null):String;
	public var longName(default, null):String;
	public var flags(default, null):UInt;
	public var range(default, null):UInt;

	// ======================================================================
	//  Constructor
	// ----------------------------------------------------------------------
	public function new(name:String, longName:String, emitCode:UInt, range:UInt, flags:UInt)
	{
		this.name = name;
		this.longName = longName;
		this.emitCode = emitCode;
		this.range = range;
		this.flags = flags;
	}

	// ======================================================================
	//  Methods
	// ----------------------------------------------------------------------
	public function toString():String
	{
		return "[Register name=\"" + name + "\", longName=\"" + longName + "\", emitCode=" + emitCode + ", range=" + range + ", flags=" + flags + "]";
	}
}

// ===========================================================================
//  Class
// ---------------------------------------------------------------------------
class Sampler
{
	// ======================================================================
	//  Properties
	// ----------------------------------------------------------------------
	public var flag(default, null):UInt;
	public var mask(default, null):UInt;
	public var name(default, null):String;

	// ======================================================================
	//  Constructor
	// ----------------------------------------------------------------------
	public function new(name:String, flag:UInt, mask:UInt)
	{
		this.name = name;
		this.flag = flag;
		this.mask = mask;
	}

	// ======================================================================
	//  Methods
	// ----------------------------------------------------------------------
	public function toString():String
	{
		return "[Sampler name=\"" + name + "\", flag=\"" + flag + "\", mask=" + mask + "]";
	}
}
