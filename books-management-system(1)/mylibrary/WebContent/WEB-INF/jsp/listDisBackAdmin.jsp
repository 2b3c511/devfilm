<%--
  Created by IntelliJ IDEA.
  User: hasee
  Date: 2019/6/1
  Time: 15:48
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String path = request.getContextPath();
    String basePath = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
            + path + "/";
%>
<html>
<head>
    <title>用户未支付订单</title>
</head>
<body class="layui-layout-body">
<div class="layui-layout layui-layout-admin">
    <jsp:include   page="header.jsp" flush="true"/>

    <!-- 搜索条件表单 -->
    <div class="demoTable layui-form">
        <div class="layui-inline">
            <input class="layui-input" name="bname" id="bname" autocomplete="off"  placeholder="请输入电影名">
        </div>
        <div class="layui-inline">
            <input class="layui-input" name="rname" id="rname" autocomplete="off" placeholder="请输入导演">
        </div>
        <div class="layui-inline">
            <div class="layui-input-block">
                <select name="state" id="state">
                    <option value="">请选择支付状态</option>
                    <option value="2">未支付</option>
                    <option value="1">已支付</option>
                </select>
            </div>
        </div>
        <button class="layui-btn" data-type="reload">搜索</button>
    </div>
<%--    <a  style="margin-left: 70px" class="layui-btn layui-btn-normal" onclick="add();">添加图书</a>--%>
</div>

<table class="layui-hide" id="demo" lay-filter="test"></table>

<div class="layui-tab-item layui-show">
    <div id="pageDemo"></div>
</div>
<script type="text/html" id="barDemo">
<%--    <a class="layui-btn layui-btn-primary layui-btn-sm" lay-event="detail">查看</a>--%>
<%--    <a class="layui-btn layui-btn-sm" lay-event="edit">编辑</a>--%>
<%--    <a class="layui-btn layui-btn-danger layui-btn-sm" lay-event="del">删除</a>--%>
    {{#  if(d.state =="2"){ }}
    <a class="layui-btn layui-btn-normal backBook" lay-event="backBook">确认支付</a>
    {{#  } }}
    {{#  if(d.state =="1"){ }}
    <button class="layui-btn  lend layui-btn-disabled backBook" lay-event="lend" disabled="disabled">已支付</button>
    {{#  } }}
</script>
<div id="testDiv"></div>
<script>
    //JavaScript代码区域
    layui.use('element', function(){
        var element = layui.element;

    });
    var url = "<%=basePath%>"
</script>

<script src="<%=basePath%>js/layui.js"></script>
<script>


    layui.config({
        version: '1554901098009' //为了更新 js 缓存，可忽略
    });


    layui.use(['laydate', 'laypage', 'layer', 'table', 'carousel', 'upload', 'element', 'slider','laytpl'], function(){
        var laydate = layui.laydate //日期
            ,laypage = layui.laypage //分页
            ,layer = layui.layer //弹层
            ,table = layui.table //表格
            ,carousel = layui.carousel //轮播
            ,upload = layui.upload //上传
            ,element = layui.element //元素操作
            ,slider = layui.slider //滑块
            ,laytpl = layui.laytpl




        //执行一个 table 实例
        table.render({
            elem: '#demo'
            ,height: 550
            ,url: '<%=basePath%>listDisBackBook.action?power=1' //数据接口
            ,title: '影片列表'
            ,page: true
            ,limit: 6
            ,limits: [5,10,15,20]
            ,cols: [[ //表头
                {type: 'checkbox', fixed: 'left'}
                ,{field: 'sernum', title: '影片编号', width:150, sort: true}
                ,{field: 'adminId', title: '购买用户ID', width:150, sort: true}
                ,{field: 'adminName', title: '购买用户', width:150}
                ,{field: 'bookName', title: '电影名', width: 150}
                ,{field: 'lend_date', title: '购买时间', width:200, sort: true}
                ,{field: 'back_date', title: '最晚支付时间', width: 200}
               /* ,{field: 'fine', title: '罚款', width: 100,templet: function(d){
                    return d.fine=="0"?'':'<a style="font-size:1.5em;color: red;font-weight: bold">'+d.fine+'元</a>';
                    }}*/
                ,{fixed: 'right', width: 200, align:'center', toolbar: '#barDemo'}
            ]]
            //用于搜索结果重载
            ,id: 'testReload'
        });

        var $ = layui.$, active = {
            reload: function(){
                var rname = $('#rname');
                var bname = $('#bname');
                var state = $('#state');
                //执行重载
                table.reload('testReload', {
                    //一定要加不然乱码
                    method: 'post'
                    ,page: {
                        curr: 1 //重新从第 1 页开始
                    }
                    ,where: {
                        //bname表示传到后台的参数,bname.val()表示具体数据
                        rname: rname.val(),
                        bname: bname.val(),
                        state: state.val()
                    }
                });
            }
        };
        $('.demoTable .layui-btn').on('click', function(){
            var type = $(this).data('type');
            active[type] ? active[type].call(this) : '';
        });


        //监听行工具事件
        table.on('tool(test)', function(obj){ //注：tool 是工具条事件名，test 是 table 原始容器的属性 lay-filter="对应的值"
            var data = obj.data //获得当前行数据
                ,layEvent = obj.event; //获得 lay-event 对应的值
           if(layEvent === 'backBook'){
                layer.confirm('确认支付订单吗？', function(index){
                    backBook(data,obj,index);
                });
            }
        });
        function backBook(data1,obj,index){
            $.ajax({
                url:'<%=basePath%>backBook.action?reader_id='+data1.adminId+'&book_id='+data1.book_id,
                dataType:'text',
                type:'post',
                success:function (data) {
                    if (data == '1'){
                        //当前行数
                        var i =$("tr").index(obj.tr)-1;
                        //获取当前dom
                        var dom = $('.backBook').eq(i);
                        if(dom.hasClass('layui-btn-normal')){
                            dom.removeClass('layui-btn-normal');
                            //变为禁用
                            dom.addClass('layui-btn-disabled');
                            //去除点击事件
                            dom.attr("disabled","disabled");
                            dom.html('已支付');
                        }
                        layer.close(index);

                    }else{
                        layer.msg('支付出错!');
                    }
                }
            })
        }
    });



</script>
</body>
</html>
