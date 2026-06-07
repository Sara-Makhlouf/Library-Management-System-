import { createAsyncThunk } from "@reduxjs/toolkit";
import api from "../../Api/aixos";
export const loginAdmin = createAsyncThunk(
  "auth/loginAdmin",
  async (loginData, thunkAPI) => {
    try {
      const response = await api.post(
  "/login",
  {
    email: loginData.email,
    password: loginData.password,
  }
);

      return response.data;
    } catch (error) {
      return thunkAPI.rejectWithValue(
        error.response?.data
      );
    }
  }
);
export default loginAdmin;