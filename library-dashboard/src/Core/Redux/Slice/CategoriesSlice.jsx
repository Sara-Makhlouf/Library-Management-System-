import {createSlice} from "@reduxjs/toolkit";
import {getcategory , getcategory} from '../Thunks/AuthorThunk'
export const categorySlice = createSlice({
    name:"category",
    initialState : {
        title:null,},
        reducers:{},
        extraReducers: (builder) =>{
builder.
addCase(getcategory.pending, (state, action) => {})
.addCase(getcategory.fulfilled, (state, action) => {})
.addCase(getcategory.rejected, (state, action) => {})

addCase(getcategory.pending, (state, action) => {})
.addCase(getcategory.fulfilled, (state, action) => {})
.addCase(getcategory.rejected, (state, action) => {})

        },
});