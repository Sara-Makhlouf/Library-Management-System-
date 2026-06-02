import { createSlice } from "@reduxjs/toolkit";
//for crude operation 
import { fetchUsers, deletUsers,getUserWithDetails
 } from "../Thunks/UserThunk";

const  userSlice = createSlice({
    name:"user",
initialState:{
users: [],
error: null,
loading:false,

},
    extraReducers : (builder) => {
        builder 
    .addCase(fetchUsers.pending, (state) => {})
    .addCase(fetchUsers.fulfilled, (state, action) => {})
    .addCase(fetchUsers.rejected, (state, action) => {})
    

    .addCase(deletUsers.pending, (state) => {})
    .addCase(deletUsers.fulfilled, (state, action) => {})
    .addCase(deletUsers.rejected, (state, action) => {})    

    .addCase(getUserWithDetails.pending, (state) => {})
    .addCase(getUserWithDetails.fulfilled, (state, action) => {})
    .addCase(getUserWithDetails.rejected, (state, action) => {})    

    }});

export default userSlice.reducer;