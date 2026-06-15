import { createSlice } from '@reduxjs/toolkit';
import { fetchSettings, updateSettingsThunk, sendNotification } from '../Thunks/SettingThunk';

const initialState = {
  settings: {
    site_name: "",
    footer_copyright: "",
    contact_phone: "",
    contact_email: "",
    facebook_url: "",
    instagram_url: "",
  },
  loading: false,
  error: null,
};

const librarySlice = createSlice({
  name: 'library',
  initialState,
  reducers: {
    setSettings: (state, action) => {
      state.settings = action.payload;
    },
  },
  extraReducers: (builder) => {
    builder
      .addCase(fetchSettings.pending, (state) => { state.loading = true; })
      .addCase(fetchSettings.fulfilled, (state, action) => {
        state.loading = false;
        state.settings = action.payload;
      })
      .addCase(fetchSettings.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message;
      })
      .addCase(updateSettingsThunk.fulfilled, (state, action) => {
        state.settings = { ...state.settings, ...action.payload };
      })
      .addCase(sendNotification.pending, (state) => { state.loading = true; })
      .addCase(sendNotification.fulfilled, (state) => { state.loading = false; })
      .addCase(sendNotification.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message;
      });
  }
});

export const { setSettings } = librarySlice.actions;
export default librarySlice.reducer;