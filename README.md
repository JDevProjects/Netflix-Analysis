# Netflix-Analysis
Netflix streaming content analysis project: built an ETL pipeline, loaded, cleaned, analyzed, and visualized Netflix content dataset using Pandas, SQL Server, and Power BI.

**Netflix Streaming Content Analysis:**
- Netflix streaming content analysis project: built an ETL pipeline, loaded, cleaned, analyzed, and visualized Netflix content dataset using Pandas, SQL Server, and Power BI.

**Project Purpose / Objective:**
- Analyzed a Netflix dataset (2008–2021) from Kaggle to extract actionable insights on content additions by year, popular genres, top directors, and country of production. The goal is to support content strategy, marketing, and subscriber engagement decisions by highlighting trends in movies and TV shows added over time.

**Netflix Streaming Content Dashboard:**

 ![Product & Sales Trends Dashboard](Dashboard-Screenshot-Netflix.png)
 
**Dashboard Overview Snapshot:**
- Select Year Slicer: Filter all visuals dynamically by year.
- Number of Movies and TV Shows Added Per Year: Line chart showing yearly content additions for movies vs TV shows.
- Number of Titles Added Per Year By Genre: Line chart tracking growth for top genres (International Movies, Dramas, Comedies, International TV Shows).
- Top 5 Countries Producing Netflix Content: Pie chart of countries with the highest content counts.
- Top Directors by Number of Titles: Bar chart highlighting directors contributing the most content.

**Key Insights for Stakeholders:**
1.	Content Growth Over Time
- Dramatic increase in titles added starting around 2015, with movies generally outpacing TV shows.
- Growth peaks around 2018–2019, followed by a noticeable decline in 2020 possibly due to COVID-19 production delays.
  
2.	Genre Popularity
- International Movies, Dramas, Comedies, and International TV Shows were the most added titles by genre.

4.	Data Coverage Note
- 10 titles with null date_added are negligible (in comparison to the large size of 101K row dataset) and do not affect overall trends.
- Dataset ends in 2021, therefore it is not possible to see if the decline that began in 2020 continues, stabilizes, or reverses.
  
6.	Geographic Distribution
- United States leads with over 57% of content, followed by India, United Kingdom, Canada, and France.
- Expanding content diversity by country could improve global subscriber appeal.
  
8.	Director Contributions
•	Top directors contribute 12–22 titles each, showing key content creators driving Netflix’s library expansion.

**Data Cleaning & Preprocessing:**
- Built an ETL pipeline: CSV data loaded into a Pandas data frame in Jupyter notebook and then loaded into SQL Server.  All data cleaning, transformation, and normalization was performed in SQL Server.
- Created a table structure in SQL Server that matches the dataset structure from Kaggle in order to import the data frame.
- Ensured foreign characters (e.g., Korean titles) were preserved in SQL Server.
- Removed duplicate titles based on title + type using row numbering.
- Normalized data by splitting columns with multiple values into separate tables: netflix_directors, netflix_country, netflix_cast, and netflix_genre.
- Converted date_added to date datatype.
- Populated missing country and duration values using mappings to other columns.
- Final cleaned table: netflix_cleaned, ready for analysis and Power BI dashboard.

**Dataset & Tools:**
- Dataset: Netflix content dataset from Kaggle
- Tools: Python (Pandas), SQL Server, Power BI Desktop

**How to Run:**
1.	Load the Netflix CSV dataset into a Pandas DataFrame using the provided Jupyter Notebook file Pandas Netflix.ipynb.
2.	Run the SQL scripts (SQL-Netflix.sql) in SQL Server to create the table structure, clean and preprocess the data, and then populate the netflix_cleaned table with cleaned and normalized data.
3.	Open the Power BI report (NetflixVisualization.pbix) in Power BI Desktop.
4.	Use the “Select Year” slicer to filter visuals dynamically.
5.	Explore dashboards for insights on content growth, genres, directors, and country distribution.

