# Pokédex Flutter — Consumo de API

Aplicación móvil desarrollada en Flutter que consume la [PokéAPI](https://pokeapi.co/) para mostrar información detallada de los Pokémon con scroll infinito.

---
## 📸 Capturas de pantalla


<p align="center">[LA APLICACION MOVIL]</p>



<p align="center">


  <img width="45%" height="1600" alt="consumo_api_1" src="https://github.com/user-attachments/assets/7d1b181c-d5a7-405d-8769-f30039108075" />

  <img width="45%" height="1600" alt="consumo_api_2" src="https://github.com/user-attachments/assets/072b4d38-b82d-4630-84bb-79ba00670f7f" />


</p>

<div align="center">


https://github.com/user-attachments/assets/f176e588-2bcb-4364-b216-74f9652c3ae4



</div>

<p align="center">
  <a href="https://github.com/user-attachments/assets/f176e588-2bcb-4364-b216-74f9652c3ae4">
    Ver demo
  </a>
</p>


---
## Actividades

### Actividad 1 — Mostrar al menos 10 elementos del personaje

Al iniciar la aplicación se cargan **10 Pokémon** de forma automática. Cada tarjeta muestra la siguiente información al expandirla:

| # | Elemento | Campo de la API |
|---|----------|----------------|
| 1 | Nombre | `name` |
| 2 | Imagen (sprite frontal) | `sprites.front_default` |
| 3 | ID | `id` |
| 4 | Altura | `height` |
| 5 | Peso | `weight` |
| 6 | XP base | `base_experience` |
| 7 | Tipo principal | `types[0].type.name` |
| 8 | Cantidad de movimientos | `moves.length` |
| 9 | HP | `stats[0].base_stat` |
| 10 | Ataque | `stats[1].base_stat` |
| 11 | Defensa | `stats[2].base_stat` |
| 12 | Velocidad | `stats[5].base_stat` |

> Las tarjetas son colapsables: se toca una para expandir/contraer sus detalles.

---

### Actividad 2 — Infinite Scrolling de 5 en 5

Se implementó **paginación infinita** usando el paquete [`infinite_scroll_pagination`](https://pub.dev/packages/infinite_scroll_pagination):

- La primera carga trae **10 Pokémon** (`limit=10, offset=0`).
- Cada vez que el usuario llega al final de la lista, se cargan **5 Pokémon más** automáticamente.
- Se utiliza `PagingController`, `PagingListener` y `PagedListView` para gestionar el estado de la paginación.

```dart
_pagingController = PagingController(
  getNextPageKey: (state) {
    if (state.lastPageIsEmpty) return null;
    if (state.pages == null || state.pages!.isEmpty) return 0;
    return state.keys!.last + 5; // avanza de 5 en 5
  },
  fetchPage: fetchPokemons,
);
```

---

## Tecnologías utilizadas

- **Flutter** — Framework principal
- **Dart** — Lenguaje de programación
- **[PokéAPI](https://pokeapi.co/)** — API REST pública de Pokémon
- **[http](https://pub.dev/packages/http)** `^1.6.0` — Peticiones HTTP
- **[infinite_scroll_pagination](https://pub.dev/packages/infinite_scroll_pagination)** `^5.1.1` — Scroll infinito

---

## Instalación y ejecución

```bash
# 1. Clonar el repositorio
git clone https://github.com/tu-usuario/consumo_api.git
cd consumo_api

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en modo debug
flutter run

# 4. Compilar APK de release
flutter build apk --release
```

> **Nota:** Se requiere conexión a internet para consumir la PokéAPI.

---

## Estructura del proyecto

```
lib/
└── main.dart          # Lógica principal: UI, paginación y consumo de API
```

---

## Vista previa

La app presenta una lista vertical de tarjetas Pokémon. Al tocar una tarjeta, se expande mostrando los 12 datos del Pokémon. Al llegar al final de la lista, se cargan 5 más automáticamente.
