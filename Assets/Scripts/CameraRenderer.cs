using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public partial class CameraRenderer
{
    private CullingResults _cullingResult;
    private ScriptableRenderContext _context;
    private Camera _camera;
    private CommandBuffer _commandBuffer;
    private const string bufferName = "Camera Render";
    private static readonly List<ShaderTagId> drawingShaderTagIds =
        new List<ShaderTagId> { new ShaderTagId("SRPDefaultUnlit"), new ShaderTagId("Custom/PlanetShader") };


    public void Render(ScriptableRenderContext context, Camera camera)
    {
        _camera = camera;
        _context = context;

        DrawUI();
        if (!Cull(out var parameters))
        {
            return;
        }

        Settings(parameters);
        DrawVisible();
        DrawUnsupportedShaders();
        DrawGizmos();
        Submit();
    }

    private void DrawUI()
    {
        if (_camera.cameraType == CameraType.SceneView)
        {
            ScriptableRenderContext.EmitWorldGeometryForSceneView(_camera);
        }
    }

    private void DrawVisible()
    {
        var drawingSettings =
            CreateDrawingSettings(drawingShaderTagIds, SortingCriteria.CommonOpaque, out SortingSettings sortingSettings);
        var filteringSettings = new FilteringSettings(RenderQueueRange.opaque);

        _context.DrawRenderers(_cullingResult, ref drawingSettings, ref filteringSettings);

        _context.DrawSkybox(_camera);

        sortingSettings.criteria = SortingCriteria.CommonTransparent;
        drawingSettings.sortingSettings = sortingSettings;
        filteringSettings.renderQueueRange = RenderQueueRange.transparent;
        _context.DrawRenderers(_cullingResult, ref drawingSettings, ref filteringSettings);

    }

    private void Settings(ScriptableCullingParameters parameters)
    {
        _commandBuffer = new CommandBuffer
            { name = _camera.name };
        _cullingResult = _context.Cull(ref parameters);
      
        _context.SetupCameraProperties(_camera);
        _commandBuffer.ClearRenderTarget(true, true, Color.clear);
        _commandBuffer.BeginSample(bufferName);
        ExecuteCommandBuffer();
    }
    private void Submit()
    {
        _commandBuffer.EndSample(bufferName);
        ExecuteCommandBuffer();
        _context.Submit();
    }

    private void ExecuteCommandBuffer()
    {
        _context.ExecuteCommandBuffer(_commandBuffer);
        _commandBuffer.Clear();
    }

    private bool Cull(out ScriptableCullingParameters parameters)
    {
        return _camera.TryGetCullingParameters(out parameters);
    }

    private DrawingSettings CreateDrawingSettings(List<ShaderTagId> shaderTags,
        SortingCriteria sortingCriteria, out SortingSettings sortingSettings)
    {
        sortingSettings = new SortingSettings(_camera)
        {
            criteria = sortingCriteria,
        };

        var drawingSettings = new DrawingSettings(shaderTags[0], sortingSettings);
        for (var i = 1; i < shaderTags.Count; i++)
        {
            drawingSettings.SetShaderPassName(i, shaderTags[i]);
        }
        return drawingSettings;
    }

    void DrawGizmos()
    {
        if (!Handles.ShouldRenderGizmos())
        {
            return;
        }
        _context.DrawGizmos(_camera, GizmoSubset.PreImageEffects);
        _context.DrawGizmos(_camera, GizmoSubset.PostImageEffects);
    }
}
