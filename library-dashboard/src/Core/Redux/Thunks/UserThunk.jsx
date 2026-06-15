import { createAsyncThunk } from "@reduxjs/toolkit";
import api from "../../Api/aixos";

export const fetchUsers = createAsyncThunk(
  "user/fetchUsers",
  async (_, thunkAPI) => {
    try {
      const response = await api.get("/users");
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
      return response.data;
      
    } catch (error) {
      console.log("Error details:", error.response);
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
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);