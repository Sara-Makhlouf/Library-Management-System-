import { useState } from "react";
import "../CSS/AddNewBook.css";

export default function AddBookPage({ onClose, onAdd }) {
  const [book, setBook] = useState({
    title: "",
    author: "",
    isbn: "",
    genre: "",
    shelf: "",
    status: "Available",
    cover: "",
    price: "",
  });

  const handleChange = (e) => {
    const { name, value } = e.target;
    setBook((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    onAdd({
      ...book,
      price: `$${book.price}`,
      cover:
        book.cover ||
        "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&q=80",
    });
  };

  return (
    <div className="add-book-overlay">
      <div className="add-book-card">
        <div className="add-book-header">
          <h2>Add New Book</h2>
          <button onClick={onClose}>✕</button>
        </div>

        <form onSubmit={handleSubmit} className="add-book-form">
          <input
            type="text"
            name="title"
            placeholder="Book Title"
            value={book.title}
            onChange={handleChange}
            required
          />

          <input
            type="text"
            name="author"
            placeholder="Author"
            value={book.author}
            onChange={handleChange}
            required
          />

          <input
            type="text"
            name="isbn"
            placeholder="ISBN"
            value={book.isbn}
            onChange={handleChange}
            required
          />

          <select
            name="genre"
            value={book.genre}
            onChange={handleChange}
            required
          >
            <option value="">Choose Genre</option>
            <option value="Historical Fiction">Historical Fiction</option>
            <option value="Scientific Journal">Scientific Journal</option>
            <option value="Technology">Technology</option>
            <option value="History">History</option>
            <option value="Science Fiction">Science Fiction</option>
          </select>

          <input
            type="text"
            name="shelf"
            placeholder="Shelf e.g. A-12"
            value={book.shelf}
            onChange={handleChange}
            required
          />

          <select
            name="status"
            value={book.status}
            onChange={handleChange}
          >
            <option value="Available">Available</option>
            <option value="Borrowed">Borrowed</option>
            <option value="Reserved">Reserved</option>
            <option value="In Repair">In Repair</option>
          </select>

          <input
            type="number"
            step="0.01"
            name="price"
            placeholder="Price"
            value={book.price}
            onChange={handleChange}
            required
          />

          <input
            type="text"
            name="cover"
            placeholder="Book Cover Image URL (optional)"
            value={book.cover}
            onChange={handleChange}
          />

          <div className="add-book-actions">
            <button type="button" className="cancel-btn" onClick={onClose}>
              Cancel
            </button>

            <button type="submit" className="save-btn">
              Save Book
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}

