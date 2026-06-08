import { createAsyncThunk } from "@reduxjs/toolkit";
import axios from "axios";


const getAuthConfig = () => ({
  headers: {
    Authorization: `Bearer ${localStorage.getItem("admin_token")}`,
    Accept: "application/json",
  },
});

export const getAllSettings = createAsyncThunk(
  "adminSettings/getAllSettings",
  async (_, { rejectWithValue }) => {
    try {
      const response = await axios.get(
        `/admin/settings`,
        getAuthConfig()
      );

      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data || "Failed to fetch settings"
      );
    }
  }
);

export const updateSettings = createAsyncThunk(
  "adminSettings/updateSettings",
  async (settings, { rejectWithValue }) => {
    try {
      const response = await axios.post(
        `/admin/settings/update`,
        { settings },
        getAuthConfig()
      );

      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data || "Failed to update settings"
      );
    }
  }
);

export const sendGlobalNotification = createAsyncThunk(
  "adminSettings/sendGlobalNotification",
  async (payload, { rejectWithValue }) => {
    try {
      const response = await axios.post(
        `/admin/notifications/global`,
        payload,
        getAuthConfig()
      );

      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data || "Failed to send notification"
      );
    }
  }
);