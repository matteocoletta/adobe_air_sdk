/**
 * AdjustIo.as
 * AdjustIo
 *
 * Created by Andrew Slotin on 2013-11-11.
 * Copyright (c) 2012-2013 adeven. All rights reserved.
 * See the file MIT-LICENSE for copying permission.
 */

package com.adeven.adjustio {
import flash.desktop.NativeApplication;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.InvokeEvent;
import flash.external.ExtensionContext;

public class AdjustIo extends EventDispatcher {
    private static var _instance: AdjustIo;
    private var extContext: ExtensionContext;

    public function onResume(): void {
        extContext.call("onResume", null);
    }

    public function onPause(): void {
        extContext.call("onPause", null);
    }

    public function trackEvent(eventToken: String, parameters: Object = null): void {
        if (parameters) {
            extContext.call("trackEvent", eventToken, new ParametersObject(parameters));
        } else {
            extContext.call("trackEvent", eventToken);
        }
    }

    public function trackRevenue(amountInCents: Number, eventToken: String = null, parameters: Object = null): void {
        if (! eventToken && parameters) {
            throw new Error("You cannot track revenue parameters without eventToken specified.")
        }
        extContext.call("trackRevenue", amountInCents, eventToken, new ParametersObject(parameters));
    }

    public static function get instance(): AdjustIo {
        _instance ||= new AdjustIo(new SingletonEnforcer());

        return _instance;
    }

    public function dispose(): void {
        extContext.dispose();
    }

    public function AdjustIo(enforcer: SingletonEnforcer) {
        super();

        extContext = ExtensionContext.createExtensionContext("com.adeven.adjustio", null);
        if (! extContext) {
            throw new Error("AdjustIo SDK is not supported on this platform.")
        }

        var app: NativeApplication = NativeApplication.nativeApplication;
        app.addEventListener(Event.ACTIVATE, handleActivation);
        app.addEventListener(Event.DEACTIVATE, handleDeactivation);
        app.addEventListener(InvokeEvent.INVOKE, handleAppLaunch)
    }

    protected function handleAppLaunch(event: Event): void {
        extContext.call("appDidLaunch");
    }

    protected function handleActivation(event: Event): void {
        onResume();
    }

    protected function handleDeactivation(event: Event): void {
        onPause();
    }
}
}

internal class ParametersObject {
    private var _source: Object = {};

    public function ParametersObject(object: Object) {
        _source = object || {};
    }

    public function getValue(key: String): * {
        return _source[key];
    }

    public function get keys(): Array {
        var k: Array = [];

        for (var key: String in _source) {
            if (_source.hasOwnProperty(key) && ! _source[key] is Function) {
                k.push(key);
            }
        }

        return k;
    }
}

internal class SingletonEnforcer {}