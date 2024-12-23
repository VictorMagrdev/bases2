create type public.tipo_seguro as enum ('publico', 'privado');
create type public.sexo as enum ('masculino', 'femenino', 'otro');
create type public.estado_cita as enum ('programada', 'en proceso', 'cancelada', 'completada');
create type public.estado_seguro as enum ('activo', 'inactivo');
create type public.forma_farmaceutica as enum ('tableta', 'ampolla', 'suspension');
create type public.estado_medicamento as enum ('pendiente', 'entregado');
create type public.tipo_informe as enum ('informe de citas', 'examenes');
create type public.estado_examen as enum ('pendiente', 'efectuado');

create table public.especialidades(
	id integer primary key default nextval('public.especialidades_id_seq'),
 	nombre varchar(65) not null unique
);

create table public.seguro_medico (
    id bigint primary key default nextval('public.seguro_medico_id_seq'),
    nombre varchar(255) not null unique,
    tipo public.tipo_seguro,
    fecha_inicio date not null,
    fecha_final date not null,
    estado public.estado_seguro,
    celular_contacto varchar(15) not null
);

create table public.pacientes (
    id serial primary key,
    nombre varchar(255) not null,
    identificacion varchar(50) unique not null,
    fecha_nacimiento date not null,
    sexo public.sexo,
    direccion varchar(255),
    email varchar(255) not null,
    celular varchar(15) not null,
    seguro_id int references public.seguro_medico(id) on delete cascade
);

create table public.medicos (
    id integer primary key default nextval('public.medicos_id_seq'),
    nombre varchar(255) not null,
    identificacion varchar(50) unique not null,
    registro_medico varchar(50) unique not null,
    especialidad_id integer,
    email varchar(255) not null,
    celular varchar(15) not null,
    foreign key (especialidad_id) references public.especialidades(id) on delete cascade
);

create table public.calendario (
    id serial primary key,
	fecha date not null,
    hora time not null,
    medico_id int references public.medicos(id)
);

create table public.citas (
    id int primary key default nextval('public.citas_id_seq'),
    fecha date not null,
    hora time not null,
    motivo varchar(255),
    estado public.estado_cita not null,
    paciente_id int references public.pacientes(id),
    medico_id int references public.medicos(id)
);

create table public.historias_clinicas (
    id bigint primary key default nextval('public.historias_clinicas_id_seq'),
    fecha date not null,
	datos jsonb not null, /*  sintomas text, diagnostico text, tratamiento text, observaciones text,*/
    cita_id int references public.citas(id)
);

create table public.medicamentos (
    id integer primary key default nextval('public.medicamentos_id_seq'),
    nombre varchar(255) not null,
    principio_activo varchar(255),
    forma_farmaceutica public.forma_farmaceutica not null,
    dosis varchar(50) not null,
    indicaciones_uso text not null,
    duracion_tratamiento varchar(50),
    estado public.estado_medicamento,
    historia_clinica_id int references public.historias_clinicas(id)
);

create table public.examenes (
    id integer primary key default nextval('public.examenes_id_seq'),
    nombre varchar(255) not null,
    costo decimal(10, 2),
    cubre_seguro boolean,
    fecha_realizacion date not null,
    estado public.estado_examen,
    historia_clinica_id int references public.historias_clinicas(id)
);

create table public.resultados_examenes (
    id integer primary key default nextval('public.resultados_examenes_id_seq'),
    diagnostico text not null,
    posible_tratamiento text not null,
    examen_id int references public.examenes(id),
    medico_id int references public.medicos(id)
);

create table public.remisiones_medicas (
    id integer primary key default nextval('public.remisiones_medicas_id_seq'),
    fecha date not null,
    motivo_remision xml,
    medico_id int references public.medicos(id),
    historia_clinica_id int references public.historias_clinicas(id)
);

create table public.informes (
    id integer primary key default nextval('public.informes_id_seq'),
    fecha date not null,
    tipo_informe public.tipo_informe,
    contenido jsonb
);


