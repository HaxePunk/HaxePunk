﻿package com.haxepunk.tweens.motion;

import com.haxepunk.Tween;
import com.haxepunk.utils.Ease;
import flash.geom.Point;

/**
 * Determines motion along a line, from one point to another.
 */
class LinearMotion extends Motion
{
	/**
	 * Constructor.
	 * @param	complete	Optional completion callback.
	 * @param	type		Tween type.
	 */
	public function new(?complete:CompleteCallback, ?type:TweenType)
	{
		_fromX = _fromY = _moveX = _moveY = 0;
		_distance = -1;
		super(0,complete, type, null);
	}

	/**
	 * Starts moving along a line.
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	duration	Duration of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotion(fromX:Float, fromY:Float, toX:Float, toY:Float, duration:Float, ease:EaseFunction = null)
	{
		_distance = -1;
		x = _fromX = fromX;
		y = _fromY = fromY;
		_moveX = toX - fromX;
		_moveY = toY - fromY;
		_target = duration;
		_ease = ease;
		start();
	}

	/**
	 * Starts moving along a line at the speed.
	 * @param	fromX		X start.
	 * @param	fromY		Y start.
	 * @param	toX			X finish.
	 * @param	toY			Y finish.
	 * @param	speed		Speed of the movement.
	 * @param	ease		Optional easer function.
	 */
	public function setMotionSpeed(fromX:Float, fromY:Float, toX:Float, toY:Float, speed:Float, ease:EaseFunction = null)
	{
		_distance = -1;
		x = _fromX = fromX;
		y = _fromY = fromY;
		_moveX = toX - fromX;
		_moveY = toY - fromY;
		_target = distance / speed;
		_ease = ease;
		start();
	}

	/** @private Updates the Tween. */
	override function _update()
	{
		super._update();
		x = _fromX + _moveX * _t;
		y = _fromY + _moveY * _t;
		if (x == _fromX + _moveX && y == _fromY + _moveY && active) finish();
	}

	/**
	 * Length of the current line of movement.
	 */
	public var distance(getDistance, null):Float;
	private function getDistance():Float
	{
		if (_distance >= 0) return _distance;
		return (_distance = Math.sqrt(_moveX * _moveX + _moveY * _moveY));
	}

	// Line information.
	private var _fromX:Float;
	private var _fromY:Float;
	private var _moveX:Float;
	private var _moveY:Float;
	private var _distance:Float;
}