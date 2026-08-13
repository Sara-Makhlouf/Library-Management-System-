import { createAsyncThunk } from "@reduxjs/toolkit";
import api from "../../Api/aixos";

export const fetchUsers = createAsyncThunk(
  "user/fetchUsers",
  async (page = 1, thunkAPI) => {
    try {
      const response = await api.get("/users", {
        params: {
          page,
        },
      });

      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);

export const deleteUser = createAsyncThunk(
  "user/deleteUser",
  async (userId, thunkAPI) => {
    try {
      const response = await api.delete(`/users/${userId}`);
      return {
        id: userId,
        data: response.data,
      };
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);

export const fetchUserWithDetails = createAsyncThunk(
  "user/fetchUserWithDetails",
  async (userId, thunkAPI) => {
    try {
      const response = await api.get(`/users/${userId}`);
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);

export const getAllOperationForUser = createAsyncThunk(
  "user/getAllOperationForUser",
  async (userId, thunkAPI) => {
    try {
      const response = await api.get(
        `/users/${userId}/full-details`
      );

      return {
        userId,
        data: response.data.data,
      };
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);