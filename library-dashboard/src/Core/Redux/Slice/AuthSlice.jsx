import { createSlice } from "@reduxjs/toolkit";
import loginAdmin from "../Thunks/AuthThunk";

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
    builder

      .addCase(loginAdmin.pending, (state) => {
        state.loading = true;
      })
.addCase(loginAdmin.fulfilled, (state, action) => {
  state.loading = false;
  state.error = null;

  state.token = action.payload.token;

  localStorage.setItem(
    "token",
    action.payload.token
  );
})

      .addCase(loginAdmin.rejected, (state, action) => {
  state.loading = false;

  state.error =
    action.payload?.message ||
    action.payload?.error ||
    "Login failed";
})

    
  },
});

export const { logout } = authSlice.actions;
export default authSlice.reducer;