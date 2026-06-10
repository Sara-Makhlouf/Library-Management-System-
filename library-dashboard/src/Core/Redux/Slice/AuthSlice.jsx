import { createSlice } from "@reduxjs/toolkit";
import loginAdmin from "../Thunks/AuthThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

const authSlice = createSlice({
  name: "auth",

  initialState: {
    user: null,
    token: localStorage.getItem("token"),
    loading: false,
    error: null,
  },

  reducers: {
    logout: (state) => {
      state.user = null;
      state.token = null;
      localStorage.removeItem("token");
    },
  },

  extraReducers: (builder) => {
    addAsyncCases(builder, loginAdmin, {
      onFulfilled: (state, action) => {
        state.token = action.payload.token;
        localStorage.setItem("token", action.payload.token);
      },
    });
  },
});

export const { logout } = authSlice.actions;
export default authSlice.reducer;
