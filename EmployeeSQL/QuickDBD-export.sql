-- Create tables in this order

CREATE TABLE "titles" (
    "title_id" varchar(255)   NOT NULL,
    "title" varchar(255)   NOT NULL,
    CONSTRAINT "pk_titles" PRIMARY KEY (
        "title_id"
     )
);

CREATE TABLE "employees" (
    "emp_no" int   NOT NULL,
    "emp_title" varchar(255)   NOT NULL references titles(title_id),
    "birth_date" Date   NOT NULL,
    "first_name" varchar(255)   NOT NULL,
    "last_name" varchar(255)   NOT NULL,
    "sex" char(1)   NOT NULL,
    "hire_date" Date   NOT NULL,
    CONSTRAINT "pk_employees" PRIMARY KEY (
        "emp_no"
     )
);

CREATE TABLE "salaries" (
    "emp_no" int NOT NULL references employees(emp_no),
    "salary" int   NOT NULL
);

CREATE TABLE "departments" (
    "dept_no" varchar(255)   NOT NULL,
    "dept_name" varchar(255)   NOT NULL,
    CONSTRAINT "pk_departments" PRIMARY KEY (
        "dept_no"
     )
);

CREATE TABLE "dept_emp" (
    "emp_no" int  NOT NULL references employees(emp_no),
    "dept_no" varchar(255)  NOT NULL references departments(dept_no)
);

CREATE TABLE "dept_manager" (
    "dept_no" varchar(255)  NOT NULL references departments(dept_no),
    "emp_no" int NOT NULL references employees(emp_no)
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
-- Employee switches departments?
SELECT *
FROM dept_emp
WHERE emp_no IN (SELECT emp_no 
                      FROM dept_emp 
                      GROUP BY emp_no 
                      HAVING COUNT(emp_no) > 1);

-- 1. List the following details of each employee: employee number, last name, first name, sex, and salary
SELECT
	employees.emp_no,
	first_name,
	last_name,
	sex,
	salary
FROM
	employees
INNER JOIN salaries 
    ON employees.emp_no = salaries.emp_no
ORDER BY emp_no;

-- 2. List first name, last name, and hire date for employees who were hired in 1986.
SELECT 
	first_name,
	last_name,
	hire_date
From employees
WHERE EXTRACT(YEAR FROM hire_date) = 1986;
-- or WHERE hire_date BETWEEN '1986-01-01' AND '1986-12-31'

-- 3. List the manager of each department with the following information: department number, department name, the manager's employee number, last name, first name.
SELECT
	departments.dept_no,
	dept_name,
	dept_manager.emp_no,
	last_name,
	first_name
	
FROM
    dept_manager
    INNER JOIN departments ON dept_manager.dept = departments.dept_no
    INNER JOIN employees ON dept_manager.emp_no = employees.emp_no

ORDER BY emp_no;

-- 4. List the department of each employee with the following information: employee number, last name, first name, and department name.
-- union dept_emp and dept_manager first then join 
-- there are 24 duplicates from Union All thus dept_emp probably contains dept_manager

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
-- d007 is Sales
SELECT dept_no
FROM departments
WHERE dept_name = 'Sales';
-- get all employess in dept_emp that has dept_no of d007

-- 7. List all employees in the Sales and Development departments, including their employee number, last name, first name, and department name.

-- 8. In descending order, list the frequency count of employee last names, i.e., how many employees share each last name.