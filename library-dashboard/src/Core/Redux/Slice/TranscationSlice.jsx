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
// في ملف TranscationSlice.js داخل الـ extraReducers
.addCase(getAllTransactions.fulfilled, (state, action) => {
  state.loading = false;
  // الوصول الصحيح هو payload.data.data بناءً على الـ Console الذي أرسلته
  const data = action.payload?.data?.data; 
  state.transactions = Array.isArray(data) ? data : [];
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
        state.successMessage = "تمت العملية بنجاح";
      })
      .addCase(checkoutTransaction.rejected, (state, action) => {
        state.checkoutLoading = false;
        // هنا نخزن الخطأ القادم من السيرفر (مثل 422) لنتمكن من عرضه في الواجهة
        state.error = action.payload;
      });
  },
});

export const {
  clearAdminTransactionsState,
} = adminTransactionsSlice.actions;

export default adminTransactionsSlice.reducer;