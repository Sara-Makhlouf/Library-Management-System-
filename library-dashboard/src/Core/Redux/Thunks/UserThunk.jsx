import { createAsyncThunk } from "@reduxjs/toolkit";
import api from "../../Api/aixos";
export const fetchUsers = createAsyncThunk(
  "user/fetchUsers",
  async (_, thunkAPI) => {
    try {
      const response = await api.get("/admin/users");


      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data || error.message
      );
    }
  }
);
export default fetchUsers;

export const deletUsers = createAsyncThunk(
    "user/deletUsers",
    async (userId, thunkAPI) => {
        try {
            const response = await api.delete("/admin/users/"+userId);
            return response.data;
        }
        catch (error) {
            return thunkAPI.rejectWithValue(
                error.response?.data || error.message
            );

        }}

);




export const fetchUserWithDetails = createAsyncThunk(
    "user/fetchUserWithDetails",
    async (userId, thunkAPI) => {
        try {
            const response = await api.get("/admin/users/"+userId);
            return response.data;
        }
        catch (error) {
            return thunkAPI.rejectWithValue(
                error.response?.data || error.message
            );

        }}

);


export const getAllOperationForUser = createAsyncThunk(
    "user/getAllOperationForUser",
    async (userId, thunkAPI) => {
        try {
            const response = await api.get("/admin/users/"+userId+"/full-details");
            return response.data;
        }
        catch (error) {
            return thunkAPI.rejectWithValue(
                error.response?.data || error.message
            );

        }}

);
