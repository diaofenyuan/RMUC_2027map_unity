using System;
using System.IO;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Rmvf.UnitySim.Editor
{
    // 独立交付包的使用者不熟悉 Assets 层级，首次打开工程时把场地场景推到前台，
    // 效果等同于在原工程里点击 U1Field.unity。
    // 用 Library 下的标记文件保证只执行一次：Library 随工程副本隔离，
    // 删除 Library 只会重新触发一次，不写 EditorPrefs，也不改写场景内容。
    [InitializeOnLoad]
    internal static class OpenFieldOnLoad
    {
        const string ScenePath = "Assets/Rmvf/Scenes/U1Field.unity";
        const int MaxAttempts = 600;

        static int attempts;

        // Application.dataPath 是 <Project>/Assets，上一级即工程根。
        static string ProjectRoot =>
            Path.GetDirectoryName(Application.dataPath) ?? string.Empty;

        static string MarkerPath =>
            Path.Combine(ProjectRoot, "Library", "RmvfFieldAutoOpened");

        // File.Exists 按进程工作目录解析，不能直接传工程相对路径。
        static string SceneFile =>
            Path.Combine(ProjectRoot, "Assets", "Rmvf", "Scenes", "U1Field.unity");

        static OpenFieldOnLoad()
        {
            // 批处理构建（-batchmode -executeMethod）必须保持当前场景，不能被这里抢开场地。
            if (Application.isBatchMode) return;
            EditorApplication.delayCall += TryOpen;
        }

        static void TryOpen()
        {
            if (File.Exists(MarkerPath)) return;
            if (!File.Exists(SceneFile)) return;              // 包不完整时保持静默，交使用者手动打开
            if (SceneManager.sceneCount > 1) return;

            // 首次打开工程时仍在导入资源，此时打开场景会拿到尚未导入的引用；等导入结束再试。
            if (EditorApplication.isUpdating || EditorApplication.isCompiling)
            {
                if (++attempts < MaxAttempts) EditorApplication.delayCall += TryOpen;
                else Debug.LogWarning("[Rmvf] 资源导入未在预期轮次内结束，请手动打开 " + ScenePath);
                return;
            }

            // 已有落盘场景说明是正常重启恢复，不覆盖使用者当前的工作状态。
            // 脏场景不再切换，避免弹出"是否保存"对话框打断使用者。
            var active = SceneManager.GetActiveScene();
            if (!string.IsNullOrEmpty(active.path)) return;
            if (active.isDirty) return;

            try
            {
                EditorSceneManager.OpenScene(ScenePath, OpenSceneMode.Single);
                Directory.CreateDirectory(Path.GetDirectoryName(MarkerPath) ?? "Library");
                File.WriteAllText(MarkerPath, DateTime.UtcNow.ToString("O"));
            }
            catch (Exception e)
            {
                Debug.LogWarning("[Rmvf] 自动打开场地场景失败，请手动打开 " + ScenePath + "：" + e.Message);
            }
        }
    }
}
