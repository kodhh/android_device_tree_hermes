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

import android.os.Bundle;
import android.os.Handler;

import androidx.preference.Preference;
import androidx.preference.Preference.OnPreferenceChangeListener;
import androidx.preference.PreferenceCategory;
import androidx.preference.PreferenceFragment;
import androidx.preference.SwitchPreferenceCompat;

import org.lineageos.settings.R;

public class DozeSettingsFragment extends PreferenceFragment implements
        OnPreferenceChangeListener {

    private static final String DOZE_ENABLED_KEY = "doze_enabled";

    private Handler mHandler = new Handler();

    private SwitchPreferenceCompat mDozeEnabledPreference;

    private SwitchPreferenceCompat mPickUpPreference;
    private SwitchPreferenceCompat mRaiseToWakePreference;
    private SwitchPreferenceCompat mHandwavePreference;
    private SwitchPreferenceCompat mPocketPreference;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        addPreferencesFromResource(R.xml.doze_settings);

        boolean dozeEnabled = DozeUtils.isDozeEnabled(getActivity());

        mDozeEnabledPreference =
                (SwitchPreferenceCompat) findPreference(DOZE_ENABLED_KEY);
        mDozeEnabledPreference.setChecked(dozeEnabled);
        mDozeEnabledPreference.setOnPreferenceChangeListener(this);

        PreferenceCategory proximitySensorCategory =
                (PreferenceCategory) findPreference(DozeUtils.CATEG_PROX_SENSOR);

        mPickUpPreference =
                (SwitchPreferenceCompat) findPreference(DozeUtils.GESTURE_PICK_UP_KEY);
        mPickUpPreference.setEnabled(dozeEnabled);
        mPickUpPreference.setOnPreferenceChangeListener(this);

        mRaiseToWakePreference =
                (SwitchPreferenceCompat) findPreference(DozeUtils.GESTURE_RAISE_TO_WAKE_KEY);
        mRaiseToWakePreference.setEnabled(dozeEnabled);
        mRaiseToWakePreference.setOnPreferenceChangeListener(this);

        mHandwavePreference =
                (SwitchPreferenceCompat) findPreference(DozeUtils.GESTURE_HAND_WAVE_KEY);
        mHandwavePreference.setEnabled(dozeEnabled);
        mHandwavePreference.setOnPreferenceChangeListener(this);

        mPocketPreference =
                (SwitchPreferenceCompat) findPreference(DozeUtils.GESTURE_POCKET_KEY);
        mPocketPreference.setEnabled(dozeEnabled);
        mPocketPreference.setOnPreferenceChangeListener(this);

        if (!DozeUtils.getProxCheckBeforePulse(getActivity())) {
            getPreferenceScreen().removePreference(proximitySensorCategory);
        }

        if (DozeUtils.isRaiseToWakeEnabled(getActivity())) {
            mPickUpPreference.setEnabled(false);
            mPocketPreference.setEnabled(false);
        }
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        if (DOZE_ENABLED_KEY.equals(preference.getKey())) {
            boolean enabled = (Boolean) newValue;
            DozeUtils.enableDoze(getActivity(), enabled);

            mPickUpPreference.setEnabled(enabled);
            mRaiseToWakePreference.setEnabled(enabled);
            mHandwavePreference.setEnabled(enabled);
            mPocketPreference.setEnabled(enabled);

            if (!enabled) {
                mPickUpPreference.setChecked(false);
                mRaiseToWakePreference.setChecked(false);
                mHandwavePreference.setChecked(false);
                mPocketPreference.setChecked(false);
            }
        } else if (DozeUtils.GESTURE_RAISE_TO_WAKE_KEY.equals(preference.getKey())) {
            boolean enabled = (Boolean) newValue;
            mPickUpPreference.setEnabled(!enabled);
            mPocketPreference.setEnabled(!enabled);
        }

        mHandler.post(() -> DozeUtils.checkDozeService(getActivity()));

        return true;
    }
}
