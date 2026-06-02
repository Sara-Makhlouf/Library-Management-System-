import { createAsyncThunk } from "@reduxjs/toolkit";
import api from "../../Api/aixos";
export const getBooksInvaliable = createAsyncThunk(
  "waitingList/getBooksInvaliable",
  async (_, thunkAPI) => {
    try {
      const response = await api.get("/admin/waiting-list");
      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data
      );
    }
  }
);
export default getBooksInvaliable;
   