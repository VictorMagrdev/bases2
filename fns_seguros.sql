--seguros medicos


create or replace procedure public.crear_seguro_medico(
    p_nombre varchar,
    p_tipo varchar,
    p_fecha_inicio date,
    p_fecha_final date,
    p_estado varchar,
    p_celular_contacto varchar
)
language plpgsql
as $$
begin
	if p_fecha_inicio > p_fecha_final then
		raise exception 'La fecha inicial debe ser menor a la final';
	end if;

    insert into public.seguro_medico(nombre, tipo, fecha_inicio, fecha_final, estado, celular_contacto)
    values (p_nombre, p_tipo::public.tipo_seguro, p_fecha_inicio, p_fecha_final, p_estado::public.estado_seguro, p_celular_contacto);
exception
	
	when unique_violation then
		rollback;
		raise notice 'El nombre ya existe en el sistema.';	

	when sqlstate '22008' then
        rollback;
        raise notice 'La fecha de nacimiento está fuera de un rango permitido.';
	
	when null_value_not_allowed then
		rollback;
		raise notice 'Uno de los valores obligatorios es NULL';
	
	when others then
		rollback;
		raise notice 'Error: Ocurrio un error inesperado: %', sqlerrm;
end;
$$;
call public.crear_seguro_medico('a','publico', '2024-11-3', '2024-11-15', 'activo', '313223234');


create or replace procedure public.eliminar_seguro_medico(p_id bigint)
language plpgsql
as $$
begin
	
	if not exists (select 1 from public.seguro_medico where id = p_id) then
        raise exception 'Error: El seguro medico con ID % no existe', p_id;
    end if;

    if exists (select 1 from seguro_medico where id = p_id and estado = 'activo') then
        raise exception 'No se puede eliminar un seguro activo. Asegúrese de que el seguro esté inactivo antes de eliminarlo.';
    end if;

    delete from seguro_medico where id = p_id;
	
exception
    when foreign_key_violation then
        raise exception 'Error: No se puede eliminar este seguro médico debido a dependencias en otras tablas.';
    when others then
        raise exception 'Error inesperado: %', sqlerrm;
end;
$$;


create or replace procedure public.modificar_seguro_medico(
    p_id bigint,
    p_nombre varchar,
    p_tipo public.tipo_seguro,
    p_fecha_inicio date,
    p_fecha_final date,
    p_celular_contacto varchar
)
language plpgsql
as $$
begin
    if not exists (select 1 from public.seguro_medico where id = p_id) then
        raise exception 'El seguro médico con ID % no existe.', p_id;
    end if;

    if p_fecha_inicio > p_fecha_final then
		raise exception 'La fecha inicial debe ser menor a la final';
	end if;

    if exists (select 1 from public.seguro_medico where id = p_id and estado = 'inactivo') then
        raise exception 'No se puede modificar un seguro inactivo. Asegúrese de que el seguro esté activo antes de modificarlo.';
    end if;

    update public.seguro_medico
    set nombre = p_nombre,
        tipo = p_tipo,
        fecha_inicio = p_fecha_inicio,
        fecha_final = p_fecha_final,
        celular_contacto = p_celular_contacto
    where id = p_id;

exception
	when foreign_key_violation then
        raise notice 'Error: No se puede modificar este seguro médico debido a dependencias en otras tablas.';

	when sqlstate '22008' then
        rollback;
        raise notice 'La fecha de nacimiento está fuera de un rango permitido.';
	
	when null_value_not_allowed then
		rollback;
		raise notice 'Uno de los valores obligatorios es NULL';
	
	when others then
		rollback;
		raise notice 'Error: Ocurrio un error inesperado: %', sqlerrm;
end;
$$;


create or replace function public.obtener_seguros_medicos()
returns table(
    id bigint,
    nombre varchar,
    tipo public.tipo_seguro,
    fecha_inicio date,
    fecha_final date,
    celular_contacto varchar
)
language plpgsql
as $$
begin
	if not exists (select 1 from public.seguro_medico) then
        raise exception 'No se encontraron registros en la tabla de pacientes.';
    end if;	
    return query select * from public.seguro_medico;
exception
	when others then
		raise notice 'Error: Ocurrio un error inesperado: %', sqlerrm;
end;
$$;

