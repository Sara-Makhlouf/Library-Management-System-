import { createSlice } from "@reduxjs/toolkit";
//for crude operation 
import { fetchUsers, deletUsers, fetchUserWithDetails
 } from "../Thunks/UserThunk";

const  userSlice = createSlice({
    name:"user",
initialState:{
users: [],
selectedUser: null,
error: null,
loading:false,

},
    extraReducers : (builder) => {
        builder 
    .addCase(fetchUsers.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(fetchUsers.fulfilled, (state, action) => {
        state.loading = false;
        state.users = action.payload;
    })
    .addCase(fetchUsers.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })
    

    .addCase(deletUsers.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(deletUsers.fulfilled, (state, action) => {
        state.loading = false;
    })
    .addCase(deletUsers.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })    

    .addCase(fetchUserWithDetails.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(fetchUserWithDetails.fulfilled, (state, action) => {
        state.loading = false;
        state.selectedUser = action.payload;
    })
    .addCase(fetchUserWithDetails.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })    

    }});

export default userSlice.reducer;
