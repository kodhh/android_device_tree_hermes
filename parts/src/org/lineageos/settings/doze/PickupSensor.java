/*
 * Copyright (C) 2015 The CyanogenMod Project
 *               2017-2020 The LineageOS Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.lineageos.settings.doze;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.PowerManager;
import android.os.PowerManager.WakeLock;
import android.os.SystemClock;
import android.util.Log;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

public class PickupSensor implements SensorEventListener {

    private static final boolean DEBUG = false;
    private static final String TAG = "PickupSensor";

    private static final int MIN_PULSE_INTERVAL_MS = 2500;
    private static final int MIN_WAKEUP_INTERVAL_MS = 1000;
    private static final int WAKELOCK_TIMEOUT_MS = 300;

    // Acceleration delta thresholds (in g) that indicate a pickup movement
    // when no hardware gesture sensor is available. Detected by the
    // accelerometer while the device is being picked up.
    private static final float ACCEL_MOVEMENT_THRESHOLD_MIN = 0.1f;
    private static final float ACCEL_MOVEMENT_THRESHOLD_MAX = 1.5f;

    private SensorManager mSensorManager;
    private Sensor mSensor;
    private Context mContext;
    private ExecutorService mExecutorService;
    private PowerManager mPowerManager;
    private WakeLock mWakeLock;

    private boolean mUseAccelerometer;
    private Sensor mProximitySensor;
    private boolean mInsidePocket = false;

    private float mAccelLast;
    private float mAccelCurrent;

    private long mEntryTimestamp;

    public PickupSensor(Context context) {
        mContext = context;
        mSensorManager = mContext.getSystemService(SensorManager.class);
        mSensor = DozeUtils.getSensor(mSensorManager, "xiaomi.sensor.pickup");
        mUseAccelerometer = mSensor == null;
        if (mUseAccelerometer) {
            mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
            mAccelLast = SensorManager.GRAVITY_EARTH;
            mAccelCurrent = SensorManager.GRAVITY_EARTH;
        }
        mProximitySensor = mSensorManager.getDefaultSensor(Sensor.TYPE_PROXIMITY, false);
        mPowerManager = (PowerManager) mContext.getSystemService(Context.POWER_SERVICE);
        mWakeLock = mPowerManager.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, TAG);
        mExecutorService = Executors.newSingleThreadExecutor();
    }

    private Future<?> submit(Runnable runnable) {
        return mExecutorService.submit(runnable);
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        boolean isRaiseToWake = DozeUtils.isRaiseToWakeEnabled(mContext);
        if (DEBUG) Log.d(TAG, "Got sensor event: " + event.values[0]);

        long delta = SystemClock.elapsedRealtime() - mEntryTimestamp;
        if (delta < (isRaiseToWake ? MIN_WAKEUP_INTERVAL_MS : MIN_PULSE_INTERVAL_MS)) {
            return;
        }

        if (!isRaiseToWake && !DozeUtils.isPocketGestureEnabled(mContext)) {
            mInsidePocket = false;
        }

        if (mInsidePocket) {
            return;
        }

        boolean detected;
        if (mUseAccelerometer) {
            float x = event.values[0];
            float y = event.values[1];
            float z = event.values[2];

            mAccelLast = mAccelCurrent;
            mAccelCurrent = (float) Math.sqrt(x * x + y * y + z * z);
            float accDelta = Math.abs(mAccelCurrent - mAccelLast);
            detected = accDelta >= ACCEL_MOVEMENT_THRESHOLD_MIN
                    && accDelta <= ACCEL_MOVEMENT_THRESHOLD_MAX;
        } else {
            detected = event.values[0] == 1;
        }

        if (!detected) {
            return;
        }

        mEntryTimestamp = SystemClock.elapsedRealtime();

        if (isRaiseToWake) {
            mWakeLock.acquire(WAKELOCK_TIMEOUT_MS);
            mPowerManager.wakeUp(SystemClock.uptimeMillis(),
                    PowerManager.WAKE_REASON_GESTURE, TAG);
        } else {
            DozeUtils.launchDozePulse(mContext);
        }
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {
        /* Empty */
    }

    private SensorEventListener mProximityListener = new SensorEventListener() {
        @Override
        public void onSensorChanged(SensorEvent event) {
            mInsidePocket = event.values[0] < mProximitySensor.getMaximumRange();
        }

        @Override
        public void onAccuracyChanged(Sensor sensor, int accuracy) {
            /* Empty */
        }
    };

    protected void enable() {
        if (DEBUG) Log.d(TAG, "Enabling");
        submit(() -> {
            mSensorManager.registerListener(this, mSensor,
                    SensorManager.SENSOR_DELAY_NORMAL);
            mSensorManager.registerListener(mProximityListener, mProximitySensor,
                    SensorManager.SENSOR_DELAY_NORMAL);
            mEntryTimestamp = SystemClock.elapsedRealtime();
        });
    }

    protected void disable() {
        if (DEBUG) Log.d(TAG, "Disabling");
        submit(() -> {
            mSensorManager.unregisterListener(this, mSensor);
            mSensorManager.unregisterListener(mProximityListener, mProximitySensor);
        });
    }
}
