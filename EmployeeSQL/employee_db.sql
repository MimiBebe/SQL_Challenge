-- Create tables in this order
-- CONSTRAINT "pk_titles" PRIMARY KEY ("title_id")
CREATE TABLE "titles" (
    "title_id" varchar(255)   NOT NULL,
    "title" varchar(255)   NOT NULL,
	PRIMARY KEY (title_id)
);

CREATE TABLE "employees" (
    "emp_no" int   NOT NULL,
    "emp_title" varchar(255)   NOT NULL,
    "birth_date" Date   NOT NULL,
    "first_name" varchar(255)   NOT NULL,
    "last_name" varchar(255)   NOT NULL,
    "sex" char(1)   NOT NULL,
    "hire_date" Date   NOT NULL,
	PRIMARY KEY (emp_no),
	FOREIGN KEY (emp_title) REFERENCES titles(title_id)
);

CREATE TABLE "salaries" (
    "emp_no" int NOT NULL,
    "salary" int   NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	PRIMARY KEY (emp_no)
);

CREATE TABLE "departments" (
    "dept_no" varchar(255)   NOT NULL,
    "dept_name" varchar(255)   NOT NULL,
	PRIMARY KEY (dept_no),
	UNIQUE(dept_name)
);

CREATE TABLE "dept_emp" (
    "emp_no" int  NOT NULL,
    "dept_no" varchar(255)  NOT NULL,
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	FOREIGN KEY (dept_no) REFERENCES departments(dept_no),
	PRIMARY KEY (emp_no,dept_no)	
);

CREATE TABLE "dept_manager" (
    "dept_no" varchar(255)  NOT NULL,
    "emp_no" int NOT NULL,
	FOREIGN KEY (dept_no) REFERENCES departments(dept_no),
	FOREIGN KEY (emp_no) REFERENCES employees(emp_no),
	PRIMARY KEY (dept_no,emp_no)
);

-- import in this order
select * from titles
select * from employees
select * from departments
select * from dept_emp
select * from dept_manager
select * from salaries

-- check for duplicates in employee
-- no duplicate
SELECT *
FROM employees
WHERE emp_no IN (SELECT emp_no 
                      FROM employees 
                      GROUP BY emp_no 
                      HAVING COUNT(emp_no) > 1);

-- check for duplicates in dept_emp
-- MANY duplicates: same emp_no for different dept_no
-- Employee switches departments or an employee works in multiple departments
SELECT *
FROM dept_emp
WHERE emp_no IN (SELECT emp_no 
                      FROM dept_emp 
                      GROUP BY emp_no 
                      HAVING COUNT(emp_no) > 1);

-- 1. List the following details of each employee: employee number, last name, first name, sex, and salary
SELECT
	Em.emp_no,
	Em.first_name,
	Em.last_name,
	Em.sex,
	Sa.salary
FROM
	employees as Em
INNER JOIN salaries as Sa 
    ON Em.emp_no = Sa.emp_no
ORDER BY Em.emp_no;

-- 2. List first name, last name, and hire date for employees who were hired in 1986.
SELECT 
	first_name,
	last_name,
	hire_date
From employees
WHERE EXTRACT(YEAR FROM hire_date) = 1986;
-- or WHERE hire_date BETWEEN '1986-01-01' AND '1986-12-31'

-- 3. List the manager of each department with the following information: department number, department name, the manager's employee number, last name, first name.
-- with aliasing
SELECT
	De.dept_no,
	De.dept_name,
	De_ma.emp_no,
	Em.last_name,
	Em.first_name
	
FROM
    dept_manager as De_ma
    INNER JOIN departments AS De ON (De_ma.dept_no = DE.dept_no)
    INNER JOIN employees AS Em ON (De_ma.emp_no = Em.emp_no)

ORDER BY Em.emp_no;

-- 4. List the department of each employee with the following information: employee number, last name, first name, and department name.

-- union dept_emp and dept_manager first then join (without aliasing) 
-- there are 24 duplicates from Union All thus dept_emp probably contains dept_manager, thus this union step technically isn't needed
CREATE VIEW dept_emp_all AS
	SELECT dept_no, emp_no FROM dept_emp
	UNION
	SELECT dept_no, emp_no FROM dept_manager;

CREATE VIEW emp_dept_names AS
	SELECT
		employees.emp_no,
		last_name,
		first_name,
		dept_name
	FROM
		employees
		INNER JOIN dept_emp_all ON employees.emp_no = dept_emp_all.emp_no
		INNER JOIN departments ON departments.dept_no = dept_emp_all.dept_no

	ORDER BY emp_no;

-- check entries: employees has 300024 while emp_dept_names has 331603
-- from duplicates above. We could remove duplicate entries
SELECT
   COUNT(*)
FROM
   employees;
 
SELECT
   COUNT(*)
FROM
   emp_dept_names;
   
-- 5. List first name, last name, and sex for employees whose first name is "Hercules" and last names begin with "B."
SELECT
	first_name,
    last_name
FROM
	employees
WHERE
	first_name = 'Hercules'
	and
	last_name LIKE 'B%';
	
-- 6. List all employees in the Sales department, including their employee number, last name, first name, and department name.
-- using the view saved above
SELECT * 
FROM emp_dept_names
WHERE dept_name = 'Sales'
ORDER BY emp_no;

-- without using the saved views
SELECT
	employees.emp_no,
	last_name,
	first_name,
	dept_name
FROM
	employees
	INNER JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
	INNER JOIN departments ON departments.dept_no = dept_emp.dept_no
WHERE
	dept_name = 'Sales'
ORDER BY emp_no;

-- 7. List all employees in the Sales and Development departments, including their employee number, last name, first name, and department name.
-- using the saved view
SELECT * 
FROM emp_dept_names
WHERE dept_name in ('Sales','Development')
ORDER BY emp_no;

-- without using the saved views
SELECT
	employees.emp_no,
	last_name,
	first_name,
	dept_name
FROM
	employees
	INNER JOIN dept_emp ON employees.emp_no = dept_emp.emp_no
	INNER JOIN departments ON departments.dept_no = dept_emp.dept_no
WHERE
	dept_name IN ('Sales','Development')
ORDER BY emp_no;

-- 8. In descending order, list the frequency count of employee last names, i.e., how many employees share each last name.
SELECT 
	last_name,
   count(last_name) as frequency
FROM 
   employees
GROUP BY 
   last_name
ORDER BY frequency DESC;

