import { createSlice } from "@reduxjs/toolkit";
import { fetchUsers, deletUsers, fetchUserWithDetails } from "../Thunks/UserThunk";
import { addAsyncCases } from "../utils/reduxHelpers";

const userSlice = createSlice({
  name: "user",
  initialState: {
    users: [],
    error: null,
    loading: false,
  },
  extraReducers: (builder) => {
    addAsyncCases(builder, fetchUsers, { dataKey: "users" });
    addAsyncCases(builder, deletUsers);
    addAsyncCases(builder, fetchUserWithDetails);
  },
});

export default userSlice.reducer;
