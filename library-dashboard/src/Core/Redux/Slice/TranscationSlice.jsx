import { createSlice } from "@reduxjs/toolkit";
import {
  getAllTransactions,
  checkoutTransaction,
} from "../Thunks/TranscationThunk";

const initialState = {
  transactions: [],
  topBorrowedBooks: [],

  loading: false,
  checkoutLoading: false,

  error: null,
  successMessage: null,

  checkoutResult: null,
};

const adminTransactionsSlice = createSlice({
  name: "adminTransactions",
  initialState,

  reducers: {
    clearAdminTransactionsState: (state) => {
      state.error = null;
      state.successMessage = null;
      state.checkoutResult = null;
    },
  },

  extraReducers: (builder) => {
    builder

      .addCase(getAllTransactions.pending, (state) => {
        state.loading = true;
        state.error = null;
      })
      .addCase(getAllTransactions.fulfilled, (state, action) => {
        state.loading = false;
        state.transactions =
          action.payload.data || action.payload;
      })
      .addCase(getAllTransactions.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

     

      .addCase(checkoutTransaction.pending, (state) => {
        state.checkoutLoading = true;
        state.error = null;
      })
      .addCase(checkoutTransaction.fulfilled, (state, action) => {
        state.checkoutLoading = false;
        state.checkoutResult = action.payload;

        state.successMessage =
          action.payload?.message ||
          "Transaction created successfully";
      })
      .addCase(checkoutTransaction.rejected, (state, action) => {
        state.checkoutLoading = false;
        state.error = action.payload;
      });
  },
});

export const {
  clearAdminTransactionsState,
} = adminTransactionsSlice.actions;

export default adminTransactionsSlice.reducer;