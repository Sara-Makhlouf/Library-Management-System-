import { createSlice } from "@reduxjs/toolkit";
import {
  getAllSettings,
  updateSettings,
  sendGlobalNotification,
} from "../Thunks/AdminThunk";

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
    builder

      .addCase(getAllSettings.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getAllSettings.fulfilled, (state, action) => {
        state.loading = false;
        state.settings = action.payload.data || action.payload;
      })
      .addCase(getAllSettings.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

      .addCase(updateSettings.pending, (state) => {
        state.updateLoading = true;
        state.error = null;
      })
      .addCase(updateSettings.fulfilled, (state, action) => {
        state.updateLoading = false;
        state.successMessage =
          action.payload.message || "Settings updated successfully";
      })
      .addCase(updateSettings.rejected, (state, action) => {
        state.updateLoading = false;
        state.error = action.payload;
      })

      .addCase(sendGlobalNotification.pending, (state) => {
        state.notificationLoading = true;
        state.error = null;
      })
      .addCase(sendGlobalNotification.fulfilled, (state, action) => {
        state.notificationLoading = false;
        state.successMessage =
          action.payload.message || "Notification sent successfully";
      })
      .addCase(sendGlobalNotification.rejected, (state, action) => {
        state.notificationLoading = false;
        state.error = action.payload;
      });
  },
});

export const { clearAdminSettingsState } =
  adminSettingsSlice.actions;

export default adminSettingsSlice.reducer;