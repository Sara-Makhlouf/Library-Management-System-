import { createAsyncThunk } from "@reduxjs/toolkit";
import axiosClient from "../../Api/aixos";

export const getAllSettings = createAsyncThunk(
  "adminSettings/getAllSettings",
  async (_, { rejectWithValue }) => {
    try {
      const response = await axiosClient.get("/settings");

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
      const response = await axiosClient.post(
        "/settings/update",
        { settings }
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
      const response = await axiosClient.post(
        "/notifications/global",
        payload
      );

      return response.data;
    } catch (error) {
      return rejectWithValue(
        error.response?.data || "Failed to send notification"
      );
    }
  }
);
