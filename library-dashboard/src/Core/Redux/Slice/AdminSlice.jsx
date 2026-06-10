import { createSlice } from "@reduxjs/toolkit";
import {
  getAllSettings,
  updateSettings,
  sendGlobalNotification,
} from "../Thunks/AdminThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

const initialState = {
  settings: [],
  loading: false,
  error: null,

  updateLoading: false,
  notificationLoading: false,

  successMessage: null,
};

const adminSettingsSlice = createSlice({
  name: "adminSettings",
  initialState,

  reducers: {
    clearAdminSettingsState: (state) => {
      state.error = null;
      state.successMessage = null;
    },
  },

  extraReducers: (builder) => {
    addAsyncCases(builder, getAllSettings, { dataKey: "settings" });

    addAsyncCases(builder, updateSettings, {
      loadingKey: "updateLoading",
      onFulfilled: (state, action) => {
        state.successMessage =
          action.payload.message || "Settings updated successfully";
      },
    });

    addAsyncCases(builder, sendGlobalNotification, {
      loadingKey: "notificationLoading",
      onFulfilled: (state, action) => {
        state.successMessage =
          action.payload.message || "Notification sent successfully";
      },
    });
  },
});

export const { clearAdminSettingsState } =
  adminSettingsSlice.actions;

export default adminSettingsSlice.reducer;
