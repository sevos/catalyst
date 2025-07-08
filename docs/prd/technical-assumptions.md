# Technical Assumptions

* **Repository Structure:** The framework will be developed and distributed as a Ruby gem, built as a Rails Engine.  
* **Service Architecture:** The core execution model will be built around ActiveJob, with a default recommendation for Solid Queue.  
* **Database Support:** The framework will support SQLite for basic functionality and assume PostgreSQL for advanced features like pgvector. It will be designed to leverage Rails' multiple-database support.  
* **Testing:** The framework itself will have comprehensive unit and integration test coverage.