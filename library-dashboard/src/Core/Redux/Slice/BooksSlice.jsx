import { createSlice } from "@reduxjs/toolkit";
import { fetchBooks, createBooks, deletBooks, updateBooks,getBooksWithDetails
 } from "../Thunks/BookThunk";

const bookSlice = createSlice({
  name: "book",

  initialState: {
    books: {data:[]},
    selectedBook: null,
    loading: false,
    error: null,
  },

  extraReducers: (builder) => {
    builder

      .addCase(fetchBooks.pending, (state) => {
        state.loading = true;
      })
   .addCase(fetchBooks.fulfilled, (state, action) => {
      console.log("PAYLOAD", action.payload);

  state.loading = false;
  state.books = action.payload;
})
      .addCase(fetchBooks.rejected, (state, action) => {
        state.loading = false;
        state.error = action.payload;
      })

      .addCase(createBooks.fulfilled, (state, action) => {
    const newBook = action.payload.data; 

    if (state.books && Array.isArray(state.books.data)) {
        state.books.data.push(newBook);
    } else {
        state.books = { data: [newBook] };
    }
})

      .addCase(deletBooks.fulfilled, (state, action) => {
  const id = action.meta.arg;

  state.books.data = state.books.data.filter(
    (b) => b.id !== id
  );

  state.books.total -= 1;
})
.addCase(updateBooks.fulfilled, (state, action) => {
    console.log("UPDATE RESPONSE", action.payload);

  const updated = action.payload;

  const index = state.books.data.findIndex(
    (b) => b.id === updated.id
  );

  if (index !== -1) {
    state.books.data[index] = updated;
  }
})
      .addCase(getBooksWithDetails.fulfilled, (state, action) => {
        state.books = action.payload;
      });
  },
});

export default bookSlice.reducer;