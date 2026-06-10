import { createSlice } from "@reduxjs/toolkit";
import { updateBookRequestStatus } from "../Thunks/BookRequestThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

const initialState = {
  loading: false,
  error: null,
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
  },

  extraReducers: (builder) => {
    addAsyncCases(builder, updateBookRequestStatus, {
      onFulfilled: (state, action) => {
        state.updatedRequest = action.payload;
        state.successMessage =
          action.payload?.message || "Book request updated successfully";
      },
    });
  },
});

export const { clearBookRequestState } =
  adminBookRequestsSlice.actions;

export default adminBookRequestsSlice.reducer;
