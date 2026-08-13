import { createSlice } from "@reduxjs/toolkit";

import {
  fetchBookRequests,
  updateBookRequestStatus,
} from "../Thunks/BookRequestThunk";

const initialState = {
  requests: [],

  loading: false,
  error: null,

  fetchLoading: false,
  fetchError: null,

  successMessage: null,
  updatedRequest: null,
};

const adminBookRequestsSlice = createSlice({
  name: "adminBookRequests",

  initialState,

  reducers: {
    clearBookRequestState: (state) => {
      state.error = null;
      state.successMessage = null;
      state.updatedRequest = null;
    },

    clearBookRequestError: (state) => {
      state.error = null;
      state.fetchError = null;
    },
  },

  extraReducers: (builder) => {
    builder

     
      .addCase(fetchBookRequests.pending, (state) => {
        state.fetchLoading = true;
        state.fetchError = null;
      })

      .addCase(fetchBookRequests.fulfilled, (state, action) => {
        state.fetchLoading = false;
        state.fetchError = null;

        state.requests = Array.isArray(action.payload)
          ? action.payload
          : [];
      })

      .addCase(fetchBookRequests.rejected, (state, action) => {
        state.fetchLoading = false;

        state.fetchError =
          action.payload || {
            message: "Failed to fetch book requests",
          };

        state.requests = [];
      })

    
      .addCase(updateBookRequestStatus.pending, (state) => {
        state.loading = true;
        state.error = null;
        state.successMessage = null;
      })

      .addCase(
        updateBookRequestStatus.fulfilled,
        (state, action) => {
          state.loading = false;
          state.error = null;

          state.updatedRequest = action.payload;

          state.successMessage =
            action.payload?.message ||
            "Book request updated successfully";

          const updated =
            action.payload?.data ||
            action.payload?.request ||
            action.payload;

          if (updated?.id) {
            const index = state.requests.findIndex(
              (request) =>
                String(request.id) === String(updated.id)
            );

            if (index !== -1) {
              state.requests[index] = updated;
            }
          }
        }
      )

      .addCase(
        updateBookRequestStatus.rejected,
        (state, action) => {
          state.loading = false;

          state.error =
            action.payload || {
              message:
                "Failed to update book request status",
            };
        }
      );
  },
});

export const {
  clearBookRequestState,
  clearBookRequestError,
} = adminBookRequestsSlice.actions;

export default adminBookRequestsSlice.reducer;