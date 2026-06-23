import { createSlice } from "@reduxjs/toolkit";
import { fetchBills, fetchBillDetails } from "../Thunks/BillThunk";

const billsSlice = createSlice({
  name: "bills",
  initialState: {
    list: [],
    pagination: null,
    currentBill: null,
    loading: false,
    detailLoading: false,
  },
  reducers: {},
  extraReducers: (builder) => {
    builder
      .addCase(fetchBills.pending, (state) => {
        state.loading = true;
      })
      .addCase(fetchBills.fulfilled, (state, action) => {
        state.loading = false;
        state.list = Array.isArray(action.payload?.data) ? action.payload.data : [];
        state.pagination = {
          currentPage: action.payload?.current_page ?? 1,
          lastPage:    action.payload?.last_page    ?? 1,
          total:       action.payload?.total        ?? 0,
          perPage:     action.payload?.per_page     ?? 15,
        };
      })
      .addCase(fetchBills.rejected, (state) => {
        state.loading = false;
      })
      .addCase(fetchBillDetails.pending, (state) => {
        state.detailLoading = true;
      })
      .addCase(fetchBillDetails.fulfilled, (state, action) => {
        state.currentBill  = action.payload;
        state.detailLoading = false;
      })
      .addCase(fetchBillDetails.rejected, (state) => {
        state.detailLoading = false;
      });
  },
});

export default billsSlice.reducer;