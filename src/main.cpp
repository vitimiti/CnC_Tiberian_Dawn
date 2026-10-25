#define SDL_MAIN_USE_CALLBACKS

#include <SDL3/SDL_main.h>

auto SDL_AppInit([[maybe_unused]] void** appstate, [[maybe_unused]] int argc,
                 [[maybe_unused]] char** argv) -> SDL_AppResult {
    return SDL_APP_CONTINUE;
}

auto SDL_AppIterate([[maybe_unused]] void* appstate) -> SDL_AppResult {
    return SDL_APP_CONTINUE;
}

auto SDL_AppEvent([[maybe_unused]] void* appstate, [[maybe_unused]] SDL_Event* event)
    -> SDL_AppResult {
    return SDL_APP_CONTINUE;
}

auto SDL_AppQuit([[maybe_unused]] void* appstate, [[maybe_unused]] SDL_AppResult result) -> void {
    SDL_Quit();
}
