import api from "../../Api/aixos";
import { createAsyncThunk } from "@reduxjs/toolkit";
export const fetchBills = createAsyncThunk('bills/fetchBills', async () => {
  const response = await api.get('/bills');
  return response.data.data.data; 
});

export const fetchBillDetails = createAsyncThunk('bills/fetchBillDetails', async (billId) => {
  const response = await api.get(`/bills/${billId}`);
  return response.data.data; 
});
