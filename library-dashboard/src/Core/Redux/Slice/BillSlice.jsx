import { createSlice } from '@reduxjs/toolkit';
import {fetchBills,fetchBillDetails} from "../Thunks/BillThunk";

const billsSlice = createSlice({
  name: 'bills',
  initialState: {
    list: [],
    currentBill: null,
    loading: false,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchBills.fulfilled, (state, action) => {
        state.list = action.payload;
      })
      .addCase(fetchBillDetails.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchBillDetails.fulfilled, (state, action) => {
        state.currentBill = action.payload;
        state.loading = false;
      });
  },
});

export default billsSlice.reducer;