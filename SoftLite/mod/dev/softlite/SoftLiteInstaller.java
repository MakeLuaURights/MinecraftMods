package dev.softlite;

import net.fabricmc.loader.api.FabricLoader;
import net.fabricmc.loader.api.entrypoint.PreLaunchEntrypoint;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Properties;

/** Copies the bundled shader pack into shaderpacks/ and selects it in Iris on first run. */
public class SoftLiteInstaller implements PreLaunchEntrypoint {
    static final String PACK = "SoftLite-Shaders.zip";

    @Override
    public void onPreLaunch() {
        try {
            install(FabricLoader.getInstance().getGameDir(), FabricLoader.getInstance().getConfigDir());
        } catch (Throwable t) {
            System.err.println("[SoftLite] could not install shader pack: " + t);
        }
    }

    static void install(Path gameDir, Path configDir) throws IOException {
        Path packs = gameDir.resolve("shaderpacks");
        Files.createDirectories(packs);
        try (InputStream in = SoftLiteInstaller.class.getResourceAsStream("/softlite/" + PACK)) {
            if (in == null) throw new IOException("pack missing from jar");
            Files.copy(in, packs.resolve(PACK), StandardCopyOption.REPLACE_EXISTING);
        }

        // Select the pack only if the player has never chosen one, so later choices are respected.
        Path cfg = configDir.resolve("iris.properties");
        Properties p = new Properties();
        if (Files.exists(cfg)) try (InputStream in = Files.newInputStream(cfg)) { p.load(in); }
        String current = p.getProperty("shaderPack");
        if (current == null || current.isBlank()) {
            p.setProperty("shaderPack", PACK);
            p.setProperty("enableShaders", "true");
            Files.createDirectories(configDir);
            try (OutputStream out = Files.newOutputStream(cfg)) { p.store(out, "Iris config (shader selected by SoftLite)"); }
        }
    }
}
