import { createSlice } from "@reduxjs/toolkit";
import {  getBooksInvaliable } from "../Thunks/WaitingListThunk";

const initialState = {
  books: null,
  loading: false,
  error: null,
};

const waitingListSlice = createSlice({
  name: "waitingList",
  initialState,
  reducers: {},

extraReducers: (builder) => {
    builder

    .addCase(getBooksInvaliable.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getBooksInvaliable.fulfilled, (state, action) => {
        state.loading = false;
        state.books = action.payload;
      })
      .addCase(getBooksInvaliable.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

  },
});

export default waitingListSlice.reducer;