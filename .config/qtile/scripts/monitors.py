import os

def amount_of_monitors():
    monitors_count = 0
    drm_path="/sys/class/drm"
    if os.path.exists(drm_path):
        for folder in os.listdir(drm_path):
            status_file = os.path.join(drm_path, folder, "status")
            if os.path.isfile(status_file):
                with open(status_file, "r") as f:
                    if f.read().strip() == "connected":
                        monitors_count += 1
    if monitors_count == 0:
        return 1

    return monitors_count


if __name__=="__main__":
    a = amount_of_monitors()
    print(a)
