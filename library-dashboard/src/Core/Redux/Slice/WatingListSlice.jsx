import { createSlice } from "@reduxjs/toolkit";
import {
  getBooksInvaliable,
  deleteFromWatingList,
  getTopWaitingList,
} from "../../Redux/Thunks/WaitingListThunk";

const waitingListSlice = createSlice({
  name: "waitingList",
  initialState: {
    items: [],
    pagination: null,
    topItems: [],
    loading: false,
    error: null,
  },

  extraReducers: (builder) => {
    builder
      .addCase(getBooksInvaliable.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getBooksInvaliable.fulfilled, (state, action) => {
        state.loading = false;
        state.items = action.payload.data.data;
        state.pagination = {
          current_page: action.payload.data.current_page,
          total: action.payload.data.total,
          last_page: action.payload.data.last_page,
        };
      })
      .addCase(getBooksInvaliable.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

      .addCase(deleteFromWatingList.pending, (state) => {
        state.loading = true;
      })
      .addCase(deleteFromWatingList.fulfilled, (state, action) => {
        state.loading = false;
        const deletedId = action.meta?.arg;
        state.items = state.items.filter((item) => item.id !== deletedId);
      })
      .addCase(deleteFromWatingList.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

      .addCase(getTopWaitingList.pending, (state) => {
        state.error = null;
      })
      .addCase(getTopWaitingList.fulfilled, (state, action) => {
        state.topItems = Array.isArray(action.payload) ? action.payload : [];
      })
      .addCase(getTopWaitingList.rejected, (state, action) => {
        state.error = action.payload;
      });
  },
});

export default waitingListSlice.reducer;