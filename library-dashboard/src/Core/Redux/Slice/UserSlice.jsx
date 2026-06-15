import { createSlice } from "@reduxjs/toolkit";
import {
  fetchUsers,
  deleteUser,
  fetchUserWithDetails,
  getAllOperationForUser,
} from "../Thunks/UserThunk";

const userSlice = createSlice({
  name: "user",
  initialState: {
    users: [],
    pagination: null,
    selectedUserOperations: null,   // ← كان ناقص
    operationsLoading: false,       // ← loading منفصل للعمليات
    error: null,
    loading: false,
  },

  extraReducers: (builder) => {
    builder
      // ── Fetch Users ──────────────────────────────────────────
      .addCase(fetchUsers.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(fetchUsers.fulfilled, (state, action) => {
        state.loading = false;
        state.users = action.payload.data.data;
        state.pagination = {
          current_page: action.payload.data.current_page,
          total: action.payload.data.total,
          last_page: action.payload.data.last_page,
        };
      })
      .addCase(fetchUsers.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message;
      })

      .addCase(deleteUser.pending, (state) => {
        state.loading = true;
      })
      .addCase(deleteUser.fulfilled, (state, action) => {
        state.loading = false;
        state.users = state.users.filter((u) => u.id !== action.payload);
      })
      .addCase(deleteUser.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message;
      })

      .addCase(fetchUserWithDetails.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchUserWithDetails.fulfilled, (state, action) => {
        state.loading = false;
        state.selectedUserOperations = action.payload.data;
      })
      .addCase(fetchUserWithDetails.rejected, (state, action) => {
        state.loading = false;
        state.error = action.error.message;
      })

      .addCase(getAllOperationForUser.pending, (state) => {
        state.operationsLoading = true;
        state.selectedUserOperations = null; 
        state.error = null;
      })
      .addCase(getAllOperationForUser.fulfilled, (state, action) => {
        state.operationsLoading = false;
        state.selectedUserOperations = action.payload.data;
      })
      .addCase(getAllOperationForUser.rejected, (state, action) => {
        state.operationsLoading = false;
        state.error = action.error.message;
      });
  },
});

export default userSlice.reducer;