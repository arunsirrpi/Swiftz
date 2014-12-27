//
//  Functor.swift
//  swiftz
//
//  Created by Josh Abernathy on 6/7/2014.
//  Copyright (c) 2014 Josh Abernathy. All rights reserved.
//

/// Encapsultes a value that may or may not exist.  A Maybe<A> contains either a value of type A or
/// nothing.
///
/// Because the nil case of Maybe does not indicate any significant information about cause, it may
/// be more appropriate to use Result or Either which have explicit error cases.
public struct Maybe<A> {
	let value: A?

	public init(_ v : A) {
		value = v
	}

	public init() { }

	/// Constructs a Maybe holding a value.
	public static func just(t : A) -> Maybe<A> {
		return Maybe(t)
	}

	/// Constructs a Maybe with no value.
	public static func none() -> Maybe {
		return Maybe()
	}

	/// Returns whether or not the reciever contains a value.
	public func isJust() -> Bool {
		switch value {
		case .Some(_): 
			return true
		case .None: 
			return false
		}
	}

	/// Returns whether or not the reciever has no value.
	public func isNone() -> Bool {
		return !isJust()
	}

	/// Forces a value from the reciever.
	///
	/// If the reciever contains no value this function will throw an exception.
	public func fromJust() -> A {
		return self.value!
	}
}

extension Maybe : BooleanType {
	public var boolValue : Bool {
		return isJust()
	}
}

/// MARK: Equatable

public func ==<A: Equatable>(lhs : Maybe<A>, rhs : Maybe<A>) -> Bool {
	if lhs.isNone() && rhs.isNone() {
		return true
	}

	if lhs && rhs {
		return lhs.fromJust() == rhs.fromJust()
	}

	return false
}

/// MARK: Functor

extension Maybe : Functor {
	typealias B = Any
	typealias FB = Maybe<B>

	public func fmap<B>(f : (A -> B)) -> Maybe<B> {
		if self.isJust() {
			let b: B = f(self.fromJust())
			return Maybe<B>.just(b)
		} else {
			return Maybe<B>.none()
		}
	}
}

extension Maybe : Applicative {
	typealias FA = Maybe<A>
	typealias FAB = Maybe<A -> B>
	
	public static func pure(a : A) -> Maybe<A>	 {
		return Maybe<A>.just(a)
	}
	
	public func ap<B>(f : Maybe<A -> B>) -> Maybe<B>	{
		if f.isJust() {
			let fn: (A -> B) = f.fromJust()
			return self.fmap(fn)
		} else {
			return Maybe<B>.none()
		}
	}
}
