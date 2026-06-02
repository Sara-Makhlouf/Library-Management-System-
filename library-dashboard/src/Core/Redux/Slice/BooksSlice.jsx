import { createSlice } from "@reduxjs/toolkit";
//for crude operation 
import { fetchBooks, createBooks, deletBooks, updateBooks, getBook,getBooksWithDetails
 } from "../Thunks/BookThunk";

const bookSlice = createSlice({
    name:"book",
initialState:{
books: [],
error: null,
loading:false,

},
    extraReducers : (builder) => {
        builder 
    .addCase(fetchBooks.pending, (state) => {})
    .addCase(fetchBooks.fulfilled, (state, action) => {})
    .addCase(fetchBooks.rejected, (state, action) => {})
    

    .addCase(createBooks.pending, (state) => {})
    .addCase(createBooks.fulfilled, (state, action) => {})
    .addCase(createBooks.rejected, (state, action) => {})    

    .addCase(deletBooks.pending, (state) => {})
    .addCase(deletBooks.fulfilled, (state, action) => {})
    .addCase(deletBooks.rejected, (state, action) => {})    

    .addCase(updateBooks.pending, (state) => {})
    .addCase(updateBooks.fulfilled, (state, action) => {})
    .addCase(updateBooks.rejected, (state, action) => {})    

    .addCase(getBook.pending, (state, action) => {})
    .addCase(getBook.fulfilled, (state, action) => {})
    .addCase(getBook.rejected, (state, action) => {})    
 
    .addCase(getBooksWithDetails.pending, (state) => {})
    .addCase(getBooksWithDetails.fulfilled, (state, action) => {})
    .addCase(getBooksWithDetails.rejected, (state, action) => {})
    }});

export default bookSlice.reducer;