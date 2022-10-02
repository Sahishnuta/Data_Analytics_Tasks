create table CovidDeaths(
	iso_code varchar(250),
	continent varchar(250),
	location varchar(250),
	date date,
	population bigint,
	total_cases	int,
	new_cases int,
	new_cases_smoothed decimal,
	total_deaths int,
	new_deaths int,
	new_deaths_smoothed decimal,
	total_cases_per_million decimal,
	new_cases_per_million decimal,
	new_cases_smoothed_per_million decimal,
	total_deaths_per_million float,
	new_deaths_per_million decimal,
	new_deaths_smoothed_per_million decimal,
	reproduction_rate decimal,
	icu_patients int,
	icu_patients_per_million float,
	hosp_patients int,
	hosp_patients_per_million float,
	weekly_icu_admissions int,
	weekly_icu_admissions_per_million float,
	weekly_hosp_admissions int,
	weekly_hosp_admissions_per_million float
	
);

COPY public.coviddeaths from 'E:\EPITA_Relation_DB\CovidDeaths.csv' DELIMITER ',' CSV HEADER;
