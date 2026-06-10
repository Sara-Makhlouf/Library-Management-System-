import { createSlice } from "@reduxjs/toolkit";
//for crude operation 
import { fetchBooks, createBooks, deletBooks, updateBooks, getBook,getBooksWithDetails
 } from "../Thunks/BookThunk";

const bookSlice = createSlice({
    name:"book",
initialState:{
books: [],
selectedBook: null,
error: null,
loading:false,

},
    extraReducers : (builder) => {
        builder 
    .addCase(fetchBooks.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(fetchBooks.fulfilled, (state, action) => {
        state.loading = false;
        state.books = action.payload;
    })
    .addCase(fetchBooks.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })
    

    .addCase(createBooks.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(createBooks.fulfilled, (state, action) => {
        state.loading = false;
    })
    .addCase(createBooks.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })    

    .addCase(deletBooks.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(deletBooks.fulfilled, (state, action) => {
        state.loading = false;
    })
    .addCase(deletBooks.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })    

    .addCase(updateBooks.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(updateBooks.fulfilled, (state, action) => {
        state.loading = false;
    })
    .addCase(updateBooks.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })    

    .addCase(getBook.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(getBook.fulfilled, (state, action) => {
        state.loading = false;
        state.selectedBook = action.payload;
    })
    .addCase(getBook.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })    
 
    .addCase(getBooksWithDetails.pending, (state) => {
        state.loading = true;
        state.error = null;
    })
    .addCase(getBooksWithDetails.fulfilled, (state, action) => {
        state.loading = false;
        state.selectedBook = action.payload;
    })
    .addCase(getBooksWithDetails.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
    })
    }});

export default bookSlice.reducer;
