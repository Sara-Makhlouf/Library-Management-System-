import { createSlice } from "@reduxjs/toolkit";

import {
  fetchUsers,
  deleteUser,
  fetchUserWithDetails,
  getAllOperationForUser,
} from "../Thunks/UserThunk";

const initialState = {
  users: [],

  pagination: null,

  profiles: {},

  profilesLoading: {},

  selectedUserOperations: null,

  operationsLoading: false,

  loading: false,

  error: null,
};

const userSlice = createSlice({
  name: "user",

  initialState,

  reducers: {
    clearSelectedUser: (state) => {
      state.selectedUserOperations = null;
    },
  },

  extraReducers: (builder) => {
    builder


      .addCase(fetchUsers.pending, (state) => {
        state.loading = true;
        state.error = null;
      })

      .addCase(fetchUsers.fulfilled, (state, action) => {
        state.loading = false;

        const data = action.payload?.data;

        state.users = data?.data || [];

        state.pagination = {
          current_page: data?.current_page || 1,
          total: data?.total || 0,
          last_page: data?.last_page || 1,
          per_page: data?.per_page || state.users.length,
        };
      })

      .addCase(fetchUsers.rejected, (state, action) => {
        state.loading = false;

        state.error =
          action.payload || action.error.message;
      })

     
      .addCase(deleteUser.pending, (state) => {
        state.error = null;
      })

      .addCase(deleteUser.fulfilled, (state, action) => {
        const deletedId = action.payload.id;

        state.users = state.users.filter(
          (user) => user.id !== deletedId
        );

        delete state.profiles[deletedId];
      })

      .addCase(deleteUser.rejected, (state, action) => {
        state.error =
          action.payload || action.error.message;
      })

      
      .addCase(fetchUserWithDetails.pending, (state) => {
        state.operationsLoading = true;
        state.error = null;
      })

      .addCase(fetchUserWithDetails.fulfilled, (state, action) => {
        state.operationsLoading = false;

        state.selectedUserOperations =
          action.payload?.data || null;
      })

      .addCase(fetchUserWithDetails.rejected, (state, action) => {
        state.operationsLoading = false;

        state.error =
          action.payload || action.error.message;
      })

      
      .addCase(
        getAllOperationForUser.pending,
        (state, action) => {
          const userId = action.meta.arg;

          state.profilesLoading[userId] = true;
        }
      )

      .addCase(
        getAllOperationForUser.fulfilled,
        (state, action) => {
          const { userId, data } = action.payload;

          state.profilesLoading[userId] = false;

         
          state.profiles[userId] = data;
        }
      )

      .addCase(
        getAllOperationForUser.rejected,
        (state, action) => {
          const userId = action.meta.arg;

          state.profilesLoading[userId] = false;

          state.error =
            action.payload || action.error.message;
        }
      );
  },
});

export const {
  clearSelectedUser,
} = userSlice.actions;

export default userSlice.reducer;