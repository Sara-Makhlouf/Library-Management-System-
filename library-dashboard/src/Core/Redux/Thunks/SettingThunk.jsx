import { createAsyncThunk } from '@reduxjs/toolkit';
import api from "../../Api/aixos"; 


export const fetchSettings = createAsyncThunk('library/fetchSettings', async () => {
  const response = await api.get(`/settings`);
  return response.data.data;
});

export const sendNotification = createAsyncThunk('library/sendNotification', async (notificationData) => {
  const response = await api.post(`/notifications/global`, notificationData);
  return response.data;
});
export const updateSettingsThunk = createAsyncThunk(
  'library/updateSettings',
  async (updatedData, { rejectWithValue }) => {
    try {
   
      const response = await api.post(`/settings/update`, { settings: updatedData }); 
      return response.data.data;
    } catch (error) {
      return rejectWithValue(error.response.data);
    }
  }
);