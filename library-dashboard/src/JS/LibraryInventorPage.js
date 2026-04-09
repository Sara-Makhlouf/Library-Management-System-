
import "../CSS/LibraryInventorPage.css";
import Sidebar from "../Components/SideBar";
import { COLORS } from "../Constants/ColorsUse";
import { useState } from "react";
import AddNewBook from "./AddNewBook";
export default function LibraryInventoryPage() {
  const [books, setBooks] = useState([
    {
      title: "The Architect's Silence",
      author: "Julian Thorne",
      isbn: "978-3-16-148410-0",
      genre: "Historical Fiction",
      shelf: "A-12",
      status: "Available",
      cover: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&q=80",
      price: "$19.99",
    },
    {
      title: "Beyond the Horizon",
      author: "Elena Mikhailov",
      isbn: "978-0-26-251763-8",
      genre: "Scientific Journal",
      shelf: "B-04",
      status: "Borrowed",
      cover: "https://images.unsplash.com/photo-1512820790803-83ca734da794?w=300&q=80",
      price: "$29.99",
    },
    {
      title: "Modern Systems Design",
      author: "Marcus Hale",
      isbn: "978-0-12-987654-3",
      genre: "Technology",
      shelf: "T-11",
      status: "Available",
      cover: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&q=80",
      price: "$39.99",
    },
    {
      title: "Empire of Sand",
      author: "Leila Hart",
      isbn: "978-1-45-763210-9",
      genre: "Historical Fiction",
      shelf: "H-03",
      status: "Reserved",
      cover: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&q=80",
      price: "$24.99",
    },
    {
      title: "The Silent Planet",
      author: "Aaron West",
      isbn: "978-8-88-654321-7",
      genre: "Science Fiction",
      shelf: "S-08",
      status: "Available",
      cover: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&q=80",
      price: "$14.99",
    },
    {
      title: "Ancient Civilizations",
      author: "Sarah Driscoll",
      isbn: "978-4-77-145632-0",
      genre: "History",
      shelf: "C-01",
      status: "Borrowed",
      cover: "https://images.unsplash.com/photo-1544947950-fa07a98d237f?w=300&q=80",
      price: "$34.99",
    },
   
  ]);
    const [currentPage, setCurrentPage] = useState(1);
const booksPerPage = 7;
const indexOfLastBook = currentPage * booksPerPage;
const indexOfFirstBook = indexOfLastBook - booksPerPage;
const currentBooks = books.slice(indexOfFirstBook, indexOfLastBook);

const totalPages = Math.ceil(books.length / booksPerPage); 
  const [showAddPage, setShowAddPage] = useState(false);
  const handleAddBook = (newBook) => {
    setBooks([...books, newBook]);
    setShowAddPage(false); 
  };
  if (showAddPage) {
    return (
      <AddNewBook 
        onAdd={handleAddBook} 
        onCancel={() => setShowAddPage(false)} 
      />
    );
  }

  return (
    <div
      className="library-layout"
      style={{
        "--primary": COLORS.Primary,
        "--secondary": COLORS.Secondary,
        "--accent": COLORS.Accent,
        "--background": COLORS.Background,
        "--text": COLORS.Text,
       display: "flex", 
    minHeight: "100vh"
          
      }}
    >
      
<Sidebar/>
      <main className="main-content" >
       
        <header className="topbar compact">
          <div className="topbar-left">
            <div>
              <h2>The Scholarly Curator</h2>
              <p>Interactive Book Inventory & Advanced Search</p>
            </div>
          </div>

          <div className="search-box">
            <span className="material-symbols-outlined">search</span>
            <input
              type="text"
              placeholder="Search by ISBN, Title, or Author..."
            />
          </div>
        </header>

        <section className="toolbar advanced-toolbar">
          <div className="filters-grid">
            <div className="filter-field">
              <label>Genre</label>
              <select>
                <option>All Genres</option>
                <option>Historical Fiction</option>
                <option>Scientific Journal</option>
                <option>Technology</option>
                <option>History</option>
              </select>
            </div>

            <div className="filter-field">

              <label>Status</label>
              <select>
                <option>Any Status</option>
                <option>Available</option>
                <option>Borrowed</option>
                <option>Reserved</option>
                <option>In Repair</option>
              </select>
            </div>

            <div className="filter-field">
              <label>Shelf</label>
              <input type="text" placeholder="e.g. A-12" />
            </div>

            <div className="filter-field">
              <label>Author</label>
              <input type="text" placeholder="Search author..." />
            </div>
          </div>

          <div className="toolbar-actions">
            <button className="clear-btn">Clear Filters</button>

           <button 
              className="add-floating-btn" 
              onClick={() => setShowAddPage(true)}
            >
              <span className="material-symbols-outlined">add</span>
              Add New Book
            </button>
          </div>
        </section>

        <section className="inventory-card">
          <table>
            <thead>
              <tr>
                <th></th>
                <th>Title & Author</th>
                <th>ISBN</th>
                <th>Genre</th>
                <th>Shelf</th>
                <th>Status</th>
                <th>Price</th>
                <th></th>
              </tr>
            </thead>

            <tbody>
              {books.map((book, index) => (
                <tr key={index}>
                  <td>
                    <input type="checkbox" />
                  </td>

                  <td>
                    <div className="book-cell">
                      <img src={book.cover} alt={book.title} />

                      <div>
                        <h4>{book.title}</h4>
                        <p>{book.author}</p>
                      </div>
                    </div>
                  </td>

                  <td>{book.isbn}</td>
                  <td>{book.genre}</td>
                  <td>
                    <span className="shelf-tag">{book.shelf}</span>
                  </td>
                  <td>
                    <span
                      className={`status-badge ${book.status
                        .toLowerCase()
                        .replace(/\s/g, "-")}`}
                    >
                      {book.status}
                    </span>
                  </td>
                  <td>${book.price}</td>
                  <td>
                  <div className="book-actions">
  <button className="more-btn">
    <span className="material-symbols-outlined">more_vert</span>
  </button>

  <div className="actions-menu">
    <button className="delete-option">
      <span className="material-symbols-outlined">delete</span>
      Delete Book
    </button>
   <button className="edit-option">
      <span className="material-symbols-outlined">edit</span>
      Edit Book
   </button>


  </div>
</div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>

       <div className="pagination-bar">
          <button 
            className="page-btn" 
            onClick={() => setCurrentPage(prev => Math.max(prev - 1, 1))}
            disabled={currentPage === 1}
          >
            ‹ Prev
          </button>

          <div className="page-numbers">
            {[...Array(totalPages)].map((_, i) => (
              <button 
                key={i} 
                className={`page-btn ${currentPage === i + 1 ? 'active' : ''}`}
                onClick={() => setCurrentPage(i + 1)}
              >
                {i + 1}
              </button>
            ))}
          </div>

          <button 
            className="page-btn" 
            onClick={() => setCurrentPage(prev => Math.min(prev + 1, totalPages))}
            disabled={currentPage === totalPages}
          >
            Next ›
          </button>
        </div>
     
    
      </main>
    </div>
  );
}