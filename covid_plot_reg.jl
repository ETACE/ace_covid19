# datahhy, datahho, dataf, castraj, unempltraj, pubacctraj, constraj,unempsectraj,tautraj = deserialize(open("100K_1704\\simdata.dat")) # read data from file
filename_prefix = ""

datapoint = fld(T,datat)
#virus related output
    inf_refy = zeros(datapoint+1,k1,k2)
    for t = 1:datapoint
        for i = 1:k1
            for j = 1:k2
                khelp = (i-1)*k2+j
                idex = datahhy[t,:,1] .== khelp
                inf_refy[t,i,j]= sum(datahhy[t,:,2][idex] .== 2)
            end
        end
    end

    plyinf = plot(datat * collect(0:fld(T,datat)),inf_refy[:,1,1])
    for i=1:k1
        for j=1:k2
            if i > 1 || j > 1
                plot!(datat * collect(0:fld(T,datat)),inf_refy[:,i,j])
            end
        end
    end
    savefig(plyinf, "$(filename_prefix)reg_infy.pdf")


    plycas = plot(datat * collect(0:fld(T,datat)),castraj[:,1,1,1])
    for i=1:k1
        for j=1:k2
            if i > 1 || j > 1
                plot!(datat * collect(0:fld(T,datat)),castraj[:,i,j,1])
            end
        end
    end
    savefig(plycas, "$(filename_prefix)reg_casy.pdf")

    inf_refo = zeros(datapoint+1,k1,k2)
    for t = 1:datapoint
        for i = 1:k1
            for j = 1:k2
                khelp = (i-1)*k2+j
                idex = datahho[t,:,1] .== khelp
                inf_refo[t,i,j]= sum(datahho[t,:,2][idex] .== 2)
            end
        end
    end

    ploinf = plot(datat * collect(0:fld(T,datat)),inf_refo[:,1,1])
    for i=1:k1
        for j=1:k2
            if i > 1 || j > 1
                plot!(datat * collect(0:fld(T,datat)),inf_refo[:,i,j])
            end
        end
    end
    savefig(ploinf, "$(filename_prefix)reg_info.pdf")


    plocas = plot(datat * collect(0:fld(T,datat)),castraj[:,1,1,2])
    for i=1:k1
        for j=1:k2
            if i > 1 || j > 1
                plot!(datat * collect(0:fld(T,datat)),castraj[:,i,j,2])
            end
        end
    end
    savefig(plocas, "$(filename_prefix)reg_caso.pdf")

    # plot fracction of infected
    hcapfrac = zeros(datapoint+1)
    for th = 1:datapoint+1
        hcapfrac[th] = hcap / (nhh * icufrac)
    end
    pl1 = plot(datat * collect(0:fld(T,datat)),[sum(datahhy[:,:,2] .== 2, dims=2) / nhhy, sum(datahho[:,:,2] .== 2, dims=2) / nhho, (sum(datahhy[:,:,2] .== 2, dims=2) .+ sum(datahho[:,:,2] .== 2, dims=2)) / nhh, hcapfrac], label = ["y" "o" "tot" "cap"])

    # plot mean of variable
    #pl2 = plot(mean(datahhy[:,:,2], dims=2))

    hhy = sum(castraj[:,:,:,1],dims=2)
    hho = sum(castraj[:,:,:,2],dims=2)
    pl3 = plot(datat * collect(0:fld(T,datat)),[sum(hhy[:,1,:],dims=2) / nhhy, sum(hho[:,1,:],dims=2) / nhho, (sum(hhy[:,1,:],dims=2) .+ sum(hho[:,1,:],dims=2)) / nhh], label = ["y" "o" "tot"])
    plt_all = plot(pl1,pl3, layout = 2)
    savefig(plt_all, "$(filename_prefix)inf_cas.pdf")
    plt_all

    # recovered
    pl1a = plot(datat * collect(0:fld(T,datat)),[sum(datahhy[:,:,2] .== 3, dims=2) / nhhy, sum(datahho[:,:,2] .== 3, dims=2) / nhho, (sum(datahhy[:,:,2] .== 3, dims=2) .+ sum(datahho[:,:,2] .== 3, dims=2)) / nhh], label = ["y" "o" "tot"])
    savefig(pl1a, "$(filename_prefix)recov.pdf")

    # determine RKIR0 factor of infected
    RKIR0traj = zeros(datat*datapoint+1)
    for t= 1:datat*datapoint+1
        if t > 8 && totinftraj[t-8] > 0
            global RKIR0traj[t] = (totinftraj[t]-totinftraj[t-4]) / (totinftraj[t-4]-totinftraj[t-8])
        end
    end
    include("emp_traj.jl")
    emptotinftraj = vcat(zeros(tpol-10),emptotinf)
    pl1b = plot(collect(0:datat*datapoint), totinftraj[:])
    plot!(emptotinftraj, linecolor = [:black])
    savefig(pl1b, "$(filename_prefix)totinf.pdf")

    pl1c = plot(collect(0:datat*datapoint), RKIR0traj[:])
    savefig(pl1c, "$(filename_prefix)RKIR0.pdf")

RKIR0smtraj = zeros(datat*datapoint+1)
for t= 1:datat*datapoint+1
    if t > 6 && RKIR0traj[t-6] > 0
        global RKIR0smtraj[t] = mean(RKIR0traj[t-6:t])
    end
end
pl1d = plot(collect(0:datat*datapoint), RKIR0smtraj[:])
savefig(pl1d, "$(filename_prefix)RKIR0sm.pdf")

pl4 = plot(datat * collect(0:fld(T,datat)),[f_av_workers[:,1],f_av_workers[:,2],f_av_workers[:,3],f_av_workers[:,4]], label = ["man" "ser" "food" "pub"])
savefig(pl4, "$(filename_prefix)av_empl.pdf")

pl4a = plot(datat * collect(0:fld(T,datat)),[f_var_workers[:,1],f_var_workers[:,2],f_var_workers[:,3],f_var_workers[:,4]], label = ["man" "ser" "food" "pub"])
savefig(pl4a, "$(filename_prefix)var_empl.pdf")

pl5 = plot(datat * collect(0:fld(T,datat)),[f_av_stock[:,1],f_av_stock[:,2],f_av_stock[:,3]], label = ["man" "ser" "food"])
savefig(pl5, "$(filename_prefix)av_stock.pdf")

consh = sum(constraj[:,:,:,:],dims=3)
pl6 = plot(datat * collect(1:fld(T,datat)),[sum(consh[2:datapoint+1,1,1,:],dims=2),sum(consh[2:datapoint+1,2,1,:],dims=2),sum(consh[2:datapoint+1,3,1,:],dims=2)], label = ["man" "ser" "food"])
savefig(pl6, "$(filename_prefix)sec_cons.pdf")

pl6a = plot(datat * collect(0:fld(T,datat)), conspercaptraj[:])
savefig(pl6a, "$(filename_prefix)cons_percap.pdf")

pl7 = plot(datat * collect(0:fld(T,datat)),[f_av_demandexp[:,1],f_av_demandexp[:,2],f_av_demandexp[:,3]], label = ["man" "ser" "food"])
savefig(pl7, "$(filename_prefix)av_demexp.pdf")

pl7a = plot(datat * collect(0:fld(T,datat)),[f_var_demandexp[:,1],f_var_demandexp[:,2],f_var_demandexp[:,3]], label = ["man" "ser" "food"])
savefig(pl7a, "$(filename_prefix)var_demexp.pdf")

pl8 = plot(datat * collect(0:fld(T,datat)),pubacctraj[:])
savefig(pl8, "$(filename_prefix)pubaccpercap.pdf")

pl9 = plot(datat * collect(0:fld(T,datat)),unempltraj[:])
savefig(pl9, "$(filename_prefix)unemp.pdf")

pl10 = plot(datat * collect(0:fld(T,datat)),tautraj[:])
savefig(pl10, "$(filename_prefix)tax.pdf")

pl11 = plot(datat * collect(0:fld(T,datat)),[f_av_savings[:,1],f_av_savings[:,2],f_av_savings[:,3]], label = ["man" "ser" "food"])
savefig(pl11, "$(filename_prefix)av_savings.pdf")

pl11a = plot(datat * collect(0:fld(T,datat)),[f_var_savings[:,1],f_var_savings[:,2],f_var_savings[:,3]], label = ["man" "ser" "food"])
savefig(pl11a, "$(filename_prefix)var_savings.pdf")

pl12 = plot(datat * collect(0:fld(T,datat)),[unempsectraj[:,1],unempsectraj[:,2],unempsectraj[:,3]], label = ["man" "ser" "food"])
savefig(pl12, "$(filename_prefix)sec_unempl.pdf")

pl13 = plot(datat * collect(0:fld(T,datat)),R0counttraj[:])
savefig(pl13, "$(filename_prefix)R0.pdf")

pl14 = plot(datat * collect(0:fld(T,datat)),gdppercaptraj[:])
savefig(pl14, "$(filename_prefix)GDPpercap.pdf")

pl14a = plot(datat * collect(0:fld(T,datat)),gdplosstraj[:])
savefig(pl14a, "$(filename_prefix)GDPloss.pdf")

pl15 = plot(datat * collect(0:fld(T,datat)),inactivefirmstraj[:])
savefig(pl15, "$(filename_prefix)inactive_firms.pdf")

pl16 = plot(datat * collect(0:fld(T,datat)),bailouttraj[:])
savefig(pl16, "$(filename_prefix)bailouts.pdf")

pl17 = plot(datat * collect(0:fld(T,datat)),shorttimetraj[:])
savefig(pl17, "$(filename_prefix)shorttime.pdf")

pl18 = plot(datat * collect(0:fld(T,datat)),[shorttimesectraj[:,1],shorttimesectraj[:,2],shorttimesectraj[:,3]], label = ["man" "ser" "food"])
savefig(pl18, "$(filename_prefix)sec_shorttime.pdf")

pl19 = plot(datat * collect(0:fld(T,datat)),totalaccountstraj[:])
savefig(pl19, "$(filename_prefix)totalaccounts.pdf")

pl20 = plot(collect(virustime:virustime+size(contact_count_traj)[1]-1), contact_count_traj[:])
#pl20 = plot(datat * collect(0:datat*datapoint),contact_count_traj[:])
savefig(pl20, "$(filename_prefix)av_contact.pdf")

pl20a = plot(collect(virustime:virustime+size(contact_work_traj)[1]-1), contact_work_traj[:])
savefig(pl20a, "$(filename_prefix)av_contact_work.pdf")

pl20b = plot(collect(virustime:virustime+size(contact_social_traj)[1]-1), contact_social_traj[:])
savefig(pl20b, "$(filename_prefix)av_contact_social.pdf")

pl20c = plot(collect(virustime:virustime+size(contact_shop_traj)[1]-1), contact_shop_traj[:])
savefig(pl20c, "$(filename_prefix)av_contact_shop.pdf")

pl21 = plot(datat * collect(0:fld(T,datat)),totfirmtraj[:])
savefig(pl21, "$(filename_prefix)totfirms.pdf")

pl22 = plot(datat * collect(0:fld(T,datat)),[bankrupttraj[:,1],bankrupttraj[:,2],bankrupttraj[:,3]], label = ["man" "ser" "food"])
savefig(pl22, "$(filename_prefix)bankruptcies.pdf")

plot(RKIR0smtraj[35:80])

plot(totinftraj[tpol-10:90])
