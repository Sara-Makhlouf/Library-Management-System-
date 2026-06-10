import { createSlice } from "@reduxjs/toolkit";
import {
  getAllTransactions,
  checkoutTransaction,
} from "../Thunks/TranscationThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

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
    addAsyncCases(builder, getAllTransactions, { dataKey: "transactions" });

    addAsyncCases(builder, checkoutTransaction, {
      loadingKey: "checkoutLoading",
      onFulfilled: (state, action) => {
        state.checkoutResult = action.payload;
        state.successMessage =
          action.payload?.message || "Transaction created successfully";
      },
    });
  },
});

export const { clearAdminTransactionsState } =
  adminTransactionsSlice.actions;

export default adminTransactionsSlice.reducer;
